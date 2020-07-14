defmodule MrTorrentWeb.Admin.TagController do
  use MrTorrentWeb, :controller

  alias MrTorrent.Torrents

  def index(conn, _params) do
    tags = Torrents.list_tags_with_counts
    render(conn, "index.html", tags: tags)
  end
end
