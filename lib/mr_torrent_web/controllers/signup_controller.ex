defmodule MrTorrentWeb.SignupController do
  use MrTorrentWeb, :controller

  import Plug.Conn

  alias MrTorrent.Accounts
  alias MrTorrentWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_signup(%MrTorrent.Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.login_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
