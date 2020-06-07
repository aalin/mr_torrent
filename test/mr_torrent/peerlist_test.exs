defmodule MrTorrent.PeerlistTest do
  use ExUnit.Case, async: true

  test "announce/3 adds a peer to the peerlist and returns it" do
    torrent = %MrTorrent.Torrents.Torrent{id: 1}
    {ip, params} = valid_params()
    assert {:ok, peerlist} = MrTorrent.Peerlist.announce(torrent, ip, params)
  end

  test "get_seeders_and_leechers/1" do
    torrent = %MrTorrent.Torrents.Torrent{id: 2}
    assert {0, 0} = MrTorrent.Peerlist.get_seeders_and_leechers(torrent)
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(MrTorrent.Peerlist, []).restart == :temporary
  end

  defp valid_params do
    ip = {127, 0, 0, 1}

    params = %{
      "peer_id" => :crypto.strong_rand_bytes(5),
      "port" => "1234",
      "left" => "0",
      "event" => "started"
    }

    {ip, params}
  end
end
