defmodule MrTorrent.Torrents.TorrentTag do
  use Ecto.Schema

  schema "torrent_tags" do
    belongs_to :torrent, MrTorrent.Torrents.Torrent
    belongs_to :tag, MrTorrent.Torrents.Tag
  end
end
