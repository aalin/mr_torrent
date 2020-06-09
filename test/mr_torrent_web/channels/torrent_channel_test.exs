defmodule MrTorrentWeb.TorrentChannelTest do
  use MrTorrentWeb.ChannelCase
  import MrTorrent.TorrentsFixtures

  describe "with an existing torrent" do
    setup do
      torrent = torrent_fixture()

      {:ok, _, socket} =
        MrTorrentWeb.UserSocket
        |> socket("user_id", %{user_id: 1})
        |> subscribe_and_join(MrTorrentWeb.TorrentChannel, "torrent:#{torrent.id}")

      %{socket: socket}
    end

    test "ping replies with status ok", %{socket: socket} do
      ref = push(socket, "ping", %{"hello" => "there"})
      assert_reply ref, :ok, %{"hello" => "there"}
    end

    test "broadcasts are pushed to the client", %{socket: socket} do
      broadcast_from!(socket, "broadcast", %{"some" => "data"})
      assert_push "broadcast", %{"some" => "data"}
    end
  end

  describe "with a non-existant torrent" do
    test "it returns an error" do
      {:error, message} =
        MrTorrentWeb.UserSocket
        |> socket("user_id", %{user_id: 1})
        |> subscribe_and_join(MrTorrentWeb.TorrentChannel, "torrent:5123123")

      assert message == "Torrent does not exist"
    end
  end
end
