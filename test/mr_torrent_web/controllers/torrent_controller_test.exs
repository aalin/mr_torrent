defmodule MrTorrentWeb.TorrentControllerTest do
  use MrTorrentWeb.ConnCase

  import MrTorrent.TorrentsFixtures

  setup :register_and_login_user

  #  describe "index" do
  #    test "lists all torrents", %{conn: conn} do
  #      conn = get(conn, Routes.torrent_path(conn, :index))
  #      assert html_response(conn, 200) =~ "Listing Torrents"
  #    end
  #  end

  describe "new torrent" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.torrent_path(conn, :new))
      assert html_response(conn, 200) =~ "Upload torrent"
    end
  end

  describe "create torrent" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.torrent_path(conn, :create), torrent: %{ uploaded_file: valid_torrent_upload() })

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.torrent_path(conn, :show, slug)

      conn = get(conn, Routes.torrent_path(conn, :show, slug))
      assert html_response(conn, 200) =~ "<h1>debian-10.4.0-amd64-netinst.iso</h1>"
    end

    #    test "renders errors when data is invalid", %{conn: conn} do
    #      conn = post(conn, Routes.torrent_path(conn, :create), torrent: %{ file: invalid_torrent_upload() })
    #      assert html_response(conn, 200) =~ "New Torrent"
    #    end
  end

  #  describe "delete torrent" do
  #    setup [:create_torrent]
  #
  #    test "deletes chosen torrent", %{conn: conn, torrent: torrent} do
  #      conn = delete(conn, Routes.torrent_path(conn, :delete, torrent))
  #      assert redirected_to(conn) == Routes.torrent_path(conn, :index)
  #      assert_error_sent 404, fn ->
  #        get(conn, Routes.torrent_path(conn, :show, torrent))
  #      end
  #    end
  #  end
end
