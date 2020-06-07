defmodule MrTorrent.Peerlist.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    schedule_telemetry_update()

    peerlists = %{}
    refs = %{}
    {:ok, {peerlists, refs}}
  end

  def has_peerlist?(server, torrent_id) do
    GenServer.call(server, {:has_peerlist?, torrent_id})
  end

  def get_peerlist(server, torrent_id) do
    GenServer.call(server, {:get_peerlist, torrent_id})
  end

  def handle_call({:has_peerlist?, torrent_id}, _from, {peerlists, refs}) do
    {:reply, Map.has_key?(peerlists, torrent_id), {peerlists, refs}}
  end

  def handle_call({:get_peerlist, torrent_id}, _from, {peerlists, refs}) do
    if peerlist = Map.get(peerlists, torrent_id) do
      {:reply, {:ok, peerlist}, {peerlists, refs}}
    else
      {:ok, pid} =
        DynamicSupervisor.start_child(MrTorrent.Peerlist.PeerlistSupervisor, MrTorrent.Peerlist)

      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, torrent_id)
      peerlists = Map.put(peerlists, torrent_id, pid)
      {:reply, {:ok, pid}, {peerlists, refs}}
    end
  end

  def handle_info(:update_telemetry, {peerlists, refs}) do
    :telemetry.execute([:mr_torrent, :peerlist, :registry], %{
      peerlist_count: Enum.count(peerlists)
    })

    schedule_telemetry_update()

    {:noreply, {peerlists, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {peerlists, refs}) do
    {torrent_id, refs} = Map.pop(refs, ref)
    peerlists = Map.delete(peerlists, torrent_id)
    {:noreply, {peerlists, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp schedule_telemetry_update do
    Process.send_after(self(), :update_telemetry, 5 * 1000)
  end
end
