defmodule MrTorrent.Torrents.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string

    belongs_to :parent, MrTorrent.Torrents.Category

    timestamps()
  end

  def new_changeset(category, attrs \\ %{}) do
    change(category, attrs)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :parent_id])
    |> validate_required([:name])
  end
end
