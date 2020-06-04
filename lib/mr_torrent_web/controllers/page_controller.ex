defmodule MrTorrentWeb.PageController do
  use MrTorrentWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
