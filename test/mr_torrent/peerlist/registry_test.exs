defmodule MrTorrent.Peerlist.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(MrTorrent.Peerlist.Registry)
    %{registry: registry}
  end

  test "creates peerlists", %{registry: registry} do
    assert {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_peerlist(registry, "foo.torrent")
  end

  test "removes peerlists on exit", %{registry: registry} do
    {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_peerlist(registry, "foo.torrent")
    assert MrTorrent.Peerlist.Registry.has_peerlist?(registry, "foo.torrent")
    GenServer.stop(peerlist)
    refute MrTorrent.Peerlist.Registry.has_peerlist?(registry, "foo.torrent")
  end
end
