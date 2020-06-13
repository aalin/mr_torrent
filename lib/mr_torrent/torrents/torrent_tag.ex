defmodule MrTorrent.Torrents.TorrentTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "torrent_tags" do
    belongs_to :torrent, MrTorrent.Torrents.Torrent
    belongs_to :tag, MrTorrent.Torrents.Tag
  end
end
