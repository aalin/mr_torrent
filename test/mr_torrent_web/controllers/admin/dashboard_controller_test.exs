defmodule MrTorrentWeb.Admin.DashboardControllerTest do
  use MrTorrentWeb.ConnCase, async: true

  describe "with a regular user" do
    setup :register_and_login_user

    test "GET /", %{conn: conn} do
      conn = get(conn, "/admin")
      assert redirected_to(conn) == Routes.torrent_path(conn, :index)
      assert get_flash(conn, :error) == "You are not an admin. This incident has been reported."
    end
  end

  describe "with an admin user" do
    setup :register_and_login_admin

    test "GET /", %{conn: conn} do
      conn = get(conn, "/admin")
      assert html_response(conn, 200) =~ "<h2>admin</h2>"
    end
  end
end
