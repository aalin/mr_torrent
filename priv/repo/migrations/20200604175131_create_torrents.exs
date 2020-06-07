defmodule MrTorrent.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :name, :string
      add :slug, :citext

      add :info, :binary
      add :info_hash, :binary

      add :total_size, :integer

      add :user_id, references(:users, on_delete: :nothing)

      add :description, :text

      timestamps()
    end

    create index(:torrents, [:user_id])
    create unique_index(:torrents, [:info_hash])
  end
end
