defmodule MrTorrentWeb.TorrentViewTest do
  use MrTorrentWeb.ConnCase, async: true

  import Phoenix.HTML, only: [safe_to_string: 1]

  alias MrTorrentWeb.TorrentView

  describe "download_torrent_link/2" do
    setup do
      conn = get(build_conn(), "/")
      torrent = %MrTorrent.Torrents.Torrent{slug: "Test_torrent"}

      %{conn: conn, torrent: torrent}
    end

    test "creates a download link with default text", %{conn: conn, torrent: torrent} do
      link =
        conn
        |> TorrentView.download_torrent_link(torrent)
        |> safe_to_string()

      assert link ==
               "<a download=\"\" href=\"/download/Test_torrent\" title=\"Download .torrent\">Download</a>"
    end

    test "creates a download link with custom text", %{conn: conn, torrent: torrent} do
      link =
        conn
        |> TorrentView.download_torrent_link(torrent, "Download torrent")
        |> safe_to_string()

      assert link ==
               "<a download=\"\" href=\"/download/Test_torrent\" title=\"Download .torrent\">Download torrent</a>"
    end

    test "creates a download link with custom title", %{conn: conn, torrent: torrent} do
      link =
        conn
        |> TorrentView.download_torrent_link(torrent, "Download torrent", title: "Download")
        |> safe_to_string()

      assert link ==
               "<a download=\"\" href=\"/download/Test_torrent\" title=\"Download\">Download torrent</a>"
    end
  end
end
