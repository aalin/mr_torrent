defmodule MrTorrent.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :name, :string
      add :slug, :string

      add :files, {:array, :map}
      add :piece_length, :integer
      add :pieces, :binary
      add :info_hash, :binary

      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:torrents, [:info_hash])
  end
end
