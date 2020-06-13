defmodule MrTorrent.Torrents.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  schema "tags" do
    field :name, :string

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
end
