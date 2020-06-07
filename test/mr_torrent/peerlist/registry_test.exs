defmodule MrTorrent.Peerlist.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(MrTorrent.Peerlist.Registry)
    %{registry: registry}
  end

  test "creates peerlists", %{registry: registry} do
    assert {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_peerlist(registry, 123)
  end

  test "removes peerlists on exit", %{registry: registry} do
    {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_peerlist(registry, 123)
    assert MrTorrent.Peerlist.Registry.has_peerlist?(registry, 123)
    GenServer.stop(peerlist)
    refute MrTorrent.Peerlist.Registry.has_peerlist?(registry, 123)
  end
end
