defmodule MrTorrent.Torrents.TorrentFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "torrent_files" do
    field :path, {:array, :string}
    field :size, :integer
    field :torrent_id, :id

    timestamps()
  end

  @doc false
  def changeset(torrent_file, attrs) do
    torrent_file
    |> cast(attrs, [:path, :size])
    |> validate_required([:path, :size])
  end
end
