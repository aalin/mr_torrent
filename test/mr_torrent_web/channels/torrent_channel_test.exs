defmodule MrTorrentWeb.TorrentChannelTest do
  use MrTorrentWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      MrTorrentWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(MrTorrentWeb.TorrentChannel, "torrent:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
