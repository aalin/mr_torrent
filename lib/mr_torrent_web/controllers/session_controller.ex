defmodule MrTorrentWeb.SessionController do
  use MrTorrentWeb, :controller

  alias MrTorrent.Accounts
  alias MrTorrentWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"username" => username, "password" => password} = user_params

    if user = Accounts.get_user_by_username_and_password(username, password) do
      UserAuth.login_user(conn, user, user_params)
    else
      render(conn, "new.html", error_message: "Invalid username or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.logout_user()
    |> put_flash(:info, "Logged out.")
  end
end
