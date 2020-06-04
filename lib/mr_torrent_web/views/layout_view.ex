defmodule MrTorrentWeb.LayoutView do
  use MrTorrentWeb, :view

  @app_version Application.spec(:mr_torrent, :vsn) |> to_string

  def app_version do
    @app_version
  end
end
