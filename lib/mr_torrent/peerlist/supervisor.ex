defmodule MrTorrent.Peerlist.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: MrTorrent.Peerlist.PeerlistSupervisor, strategy: :one_for_one},
      {MrTorrent.Peerlist.Registry, name: MrTorrent.Peerlist.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
