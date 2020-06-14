defmodule MrTorrentWeb.Admin.CategoryController do
  use MrTorrentWeb, :controller

  def index(conn, params) do
    categories = MrTorrent.Torrents.list_categories
    render(conn, "index.html", categories: categories)
  end
end
