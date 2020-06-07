defmodule MrTorrent.Peerlist do
  use Agent, restart: :temporary

  alias MrTorrent.Peerlist.Registry

  @peer_timeout 5 * 60 + 30
  @max_peers 50

  def start_link([]) do
    Agent.start_link(fn -> %{} end)
  end

  def get_seeders_and_leechers(%MrTorrent.Torrents.Torrent{id: torrent_id}) do
    {:ok, peerlist} = Registry.get_peerlist(Registry, torrent_id)

    peers = Agent.get(peerlist, & &1)

    Enum.reduce(peers, {0, 0}, fn {_key, %{left: left}}, {seeders, leechers} ->
      if left == 0 do
        {seeders + 1, leechers}
      else
        {seeders, leechers + 1}
      end
    end)
  end

  def announce(%MrTorrent.Torrents.Torrent{id: torrent_id}, ip, params) do
    {:ok, peerlist} = Registry.get_peerlist(Registry, torrent_id)
    update_peerlist(peerlist, ip, params)
  end

  defp update_peerlist(agent, ip, params)
       when is_pid(agent) do
    peer_id = Map.fetch!(params, "peer_id")
    ip = Map.get(params, "ip", ip)
    {port, _} = Integer.parse(Map.fetch!(params, "port"))
    {bytes_left, _} = Integer.parse(Map.fetch!(params, "left"))

    key = {peer_id, ip, port}

    case params["event"] do
      "stopped" ->
        Agent.update(agent, &Map.delete(&1, key))

      _ ->
        value = %{
          updated_at: Time.utc_now(),
          left: bytes_left
        }

        Agent.update(agent, &Map.put(&1, key, value))
    end

    delete_old_peers(agent)

    numwant = Map.get(params, "numwant", @max_peers)

    get_peers(agent, numwant)
  end

  defp get_peers(agent, count)
       when is_number(count) do
    peers =
      Agent.get(agent, & &1)
      |> Map.keys()
      |> Enum.shuffle()
      |> Enum.slice(0, Kernel.max(0, Kernel.min(count, @max_peers)))
      |> Enum.map(fn {id, ip, port} ->
        %{
          peer_id: URI.encode(id),
          ip: :inet.ntoa(ip),
          port: port
        }
      end)

    if Enum.empty?(peers), do: Agent.stop(agent)

    {:ok, peers}
  end

  defp delete_old_peers(agent) do
    now = Time.utc_now()

    Agent.update(agent, fn peers ->
      Enum.reject(peers, fn {_key, value} ->
        should_peer_be_deleted?(now, value)
      end)
      |> Map.new()
    end)
  end

  def should_peer_be_deleted?(time, %{updated_at: updated_at}) do
    Time.diff(time, updated_at) > @peer_timeout
  end
end
