defmodule MrTorrent.Repo.Migrations.CreateAccesses do
  use Ecto.Migration

  def change do
    create table(:accesses) do
      add :token, :binary
      add :torrent_id, references(:torrents, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:accesses, [:torrent_id])
    create index(:accesses, [:user_id])
    create unique_index(:accesses, [:torrent_id, :user_id])
    create unique_index(:accesses, [:token])
  end
end
