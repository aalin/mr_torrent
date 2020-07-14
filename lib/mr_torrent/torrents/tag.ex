defmodule MrTorrent.Torrents.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  schema "tags" do
    field :name, :string

    field :torrents_count, :integer, virtual: true

    many_to_many :torrents, MrTorrent.Torrents.Torrent,
      join_through: MrTorrent.Torrents.TorrentTag

    timestamps()
  end

  def new_changeset(attrs) do
    %MrTorrent.Torrents.Tag{}
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def update_changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def get_all_query(names) do
    from t in MrTorrent.Torrents.Tag,
      where: t.name in ^names
  end

  def get_all_with_counts_query do
    from tag in MrTorrent.Torrents.Tag,
      left_join: torrents in assoc(tag, :torrents),
      group_by: tag.id,
      select_merge: %{:torrents_count => count(torrents)},
      order_by: [desc: count(torrents)]
  end
end
