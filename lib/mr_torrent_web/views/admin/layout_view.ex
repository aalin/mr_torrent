defmodule MrTorrentWeb.Admin.LayoutView do
  use MrTorrentWeb, :view

  def app_version do
    Application.spec(:mr_torrent, :vsn)
  end
end
