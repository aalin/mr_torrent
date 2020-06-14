defmodule MrTorrentWeb.Admin.UserController do
  use MrTorrentWeb, :controller

  def index(conn, params) do
    users = MrTorrent.Accounts.paginate_users(params)
    render(conn, "index.html", users: users)
  end
end
