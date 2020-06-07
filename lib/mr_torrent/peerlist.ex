defmodule MrTorrent.Peerlist do
  use Agent, restart: :temporary

  alias MrTorrent.Peerlist.Registry

  @peer_timeout 5 * 60 + 30
  @max_peers 50

  def start_link(torrent_id) do
    Agent.start_link(fn -> %{id: torrent_id, peers: %{}} end)
  end

  def get_seeders_and_leechers(%MrTorrent.Torrents.Torrent{id: torrent_id}) do
    {:ok, peerlist} = Registry.get_peerlist(Registry, torrent_id)

    peers = Agent.get(peerlist, & &1).peers

    Enum.reduce(peers, {0, 0}, fn {_key, %{left: left}}, {seeders, leechers} ->
      if left == 0 do
        {seeders + 1, leechers}
      else
        {seeders, leechers + 1}
      end
    end)
  end

  def announce(%MrTorrent.Torrents.Torrent{id: torrent_id}, ip, params) do
    {:ok, agent} = Registry.get_peerlist(Registry, torrent_id)

    update_peer(agent, ip, params)

    delete_old_peers(agent)
    broadcast_seeders_and_leechers(agent)

    get_peers(agent)
  end

  defp update_peer(agent, ip, params) do
    peer_id = Map.fetch!(params, "peer_id")
    ip = Map.get(params, "ip", ip)
    port = Map.fetch!(params, "port") |> String.to_integer

    key = {peer_id, ip, port}

    if params["event"] == "stopped" do
      Agent.update(agent, fn %{id: id, peers: peers} ->
        %{id: id, peers: Map.delete(peers, key)}
      end)
    else
      value = %{
        updated_at: Time.utc_now(),
        left: Map.fetch!(params, "left") |> String.to_integer
      }

      Agent.update(agent, fn %{id: id, peers: peers} ->
        %{id: id, peers: Map.put(peers, key, value)}
      end)
    end
  end

  defp get_peers(agent) do
    peers =
      Agent.get(agent, & &1).peers
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

    {:ok, peers}
  end

  defp delete_old_peers(agent) do
    now = Time.utc_now()

    Agent.update(agent, fn state ->
      Map.put(
        state,
        :peers,
        Enum.reject(state.peers, fn {_key, value} ->
          should_peer_be_deleted?(now, value)
        end) |> Map.new()
      )
    end)
  end

  def should_peer_be_deleted?(time, %{updated_at: updated_at}) do
    Time.diff(time, updated_at) > @peer_timeout
  end

  defp broadcast_seeders_and_leechers(agent) do
    id = Agent.get(agent, & &1).id
    {seeders, leechers} = get_seeders_and_leechers(%MrTorrent.Torrents.Torrent{id: id})
    MrTorrentWeb.Endpoint.broadcast("torrent:#{id}", "update_fields", %{seeders: seeders, leechers: leechers})
  end
end
