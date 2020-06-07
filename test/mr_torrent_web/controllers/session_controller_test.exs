defmodule MrTorrentWeb.SessionControllerTest do
  use MrTorrentWeb.ConnCase

  import MrTorrent.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "new user_session" do
    test "renders login page", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Log in"
    end
  end

  describe "create user_session" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.session_path(conn, :create), %{
          "user" => %{
            "username" => user.username,
            "password" => valid_user_password()
          }
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Logout"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.session_path(conn, :create), %{
          "user" => %{
            "username" => user.username,
            "password" => "invalid"
          }
        })

      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "delete user_session" do
    test "logs the user out ", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> delete(Routes.session_path(conn, :delete))

      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
    end
  end
end
