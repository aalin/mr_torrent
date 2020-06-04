defmodule MrTorrentWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias MrTorrent.Accounts
  alias MrTorrentWeb.Router.Helpers, as: Routes

  def login_user(conn, user, _params \\ %{}) do
    token = Accounts.create_user_session(user)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> redirect(to: "/")
  end

  def fetch_current_user(conn, _opts) do
    token = get_session(conn, :user_token)
    user = token && Accounts.get_user_by_session_token(token)
    assign(conn, :current_user, user)
  end

  def redirect_if_user_is_authenticated(conn) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end

  def require_authenticated_user(conn) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You have to log in")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  def logout_user(conn) do
    token = get_session(conn, :user_token)
    token && Accounts.delete_user_session(token)

    conn
    |> renew_session()
    |> redirect(to: "/")
  end
end
