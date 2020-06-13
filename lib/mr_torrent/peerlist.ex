defmodule MrTorrent.Peerlist do
  use GenServer, restart: :temporary

  alias MrTorrent.Peerlist.Registry

  @peer_timeout 5 * 60 + 30
  @max_peers 50

  def start_link(torrent_id)
      when is_integer(torrent_id) do
    GenServer.start_link(__MODULE__, torrent_id)
  end

  def init(torrent_id)
      when is_integer(torrent_id) do
    state = %{id: torrent_id, peers: %{}}
    {:ok, state}
  end

  def get_seeders_and_leechers(server) when is_pid(server) do
    GenServer.call(server, :get_seeders_and_leechers)
  end

  def get_seeders_and_leechers(%MrTorrent.Torrents.Torrent{id: torrent_id}) do
    case Registry.get_peerlist(Registry, torrent_id) do
      {:ok, server} ->
        get_seeders_and_leechers(server)

      {:error, :peerlist_not_found} ->
        {0, 0}
    end
  end

  def get_peers(server) do
    GenServer.call(server, :get_peers)
  end

  def announce(%MrTorrent.Torrents.Torrent{id: torrent_id}, ip, params) do
    {:ok, server} = Registry.get_or_create_peerlist(Registry, torrent_id)

    update_peer(server, ip, params)

    delete_old_peers(server)
    broadcast_seeders_and_leechers(server)

    {:ok, get_peers(server)}
  end

  def broadcast_seeders_and_leechers(server) do
    GenServer.cast(server, :broadcast_seeders_and_leechers)
  end

  defp update_peer(server, ip, params) do
    event = Map.get(params, "event", "none")
    peer_id = Map.fetch!(params, "peer_id") |> URI.decode()
    ip = Map.get(params, "ip", ip)
    port = Map.fetch!(params, "port") |> String.to_integer()
    left = Map.fetch!(params, "left") |> String.to_integer()

    GenServer.cast(server, {:update_peer, event, peer_id, ip, port, left})
  end

  defp delete_old_peers(server) do
    GenServer.cast(server, :delete_old_peers)
  end

  def handle_call(:get_seeders_and_leechers, _from, state) do
    {:reply, count_seeders_and_leechers(state.peers), state}
  end

  def handle_call(:get_peers, _from, state) do
    peers =
      state.peers
      |> Map.keys()
      |> Enum.shuffle()
      |> Enum.slice(0, @max_peers)
      |> Enum.map(fn {id, ip, port} ->
        %{
          peer_id: URI.encode(id),
          ip: :inet.ntoa(ip),
          port: port
        }
      end)

    {:reply, peers, state}
  end

  def handle_cast({:update_peer, "stopped", peer_id, ip, port, _left}, state) do
    key = {peer_id, ip, port}

    {:noreply, %{state | peers: Map.delete(state.peers, key)}}
  end

  def handle_cast({:update_peer, _event, peer_id, ip, port, left}, state) do
    key = {peer_id, ip, port}

    value = %{
      updated_at: Time.utc_now(),
      left: left
    }

    peers = Map.put(state.peers, key, value)

    {:noreply, %{state | peers: peers}}
  end

  def handle_cast(:delete_old_peers, state) do
    now = Time.utc_now()

    peers =
      Enum.reject(state.peers, fn {_key, peer} ->
        Time.diff(now, peer.updated_at) > @peer_timeout
      end)
      |> Map.new()

    {:noreply, %{state | peers: peers}}
  end

  def handle_cast(:broadcast_seeders_and_leechers, state) do
    {seeders, leechers} = count_seeders_and_leechers(state.peers)

    MrTorrentWeb.Endpoint.broadcast("torrent:#{state.id}", "update_fields", %{
      seeders: seeders,
      leechers: leechers
    })

    {:noreply, state}
  end

  def count_seeders_and_leechers(peers) do
    Enum.reduce(peers, {0, 0}, fn {_key, %{left: left}}, {seeders, leechers} ->
      if left == 0 do
        {seeders + 1, leechers}
      else
        {seeders, leechers + 1}
      end
    end)
  end
end
