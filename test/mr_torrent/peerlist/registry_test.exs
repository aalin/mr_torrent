defmodule MrTorrent.Peerlist.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(MrTorrent.Peerlist.Registry)
    %{registry: registry}
  end

  test "get_peerlist/2 gets peerlists", %{registry: registry} do
    MrTorrent.Peerlist.Registry.get_or_create_peerlist(registry, 123)
    assert {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_peerlist(registry, 123)
    assert is_pid(peerlist)
  end

  test "get_peerlist/2 returns an error if there is no peerlist", %{registry: registry} do
    assert {:error, :peerlist_not_found} = MrTorrent.Peerlist.Registry.get_peerlist(registry, 234)
  end

  test "get_or_create_peerlist/2 creates peerlists", %{registry: registry} do
    assert {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_or_create_peerlist(registry, 345)
  end

  test "removes peerlists on exit", %{registry: registry} do
    {:ok, peerlist} = MrTorrent.Peerlist.Registry.get_or_create_peerlist(registry, 345)
    assert MrTorrent.Peerlist.Registry.has_peerlist?(registry, 345)
    GenServer.stop(peerlist)
    refute MrTorrent.Peerlist.Registry.has_peerlist?(registry, 345)
  end
end
