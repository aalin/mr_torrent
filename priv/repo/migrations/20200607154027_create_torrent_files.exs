defmodule MrTorrent.Repo.Migrations.CreateTorrentFiles do
  use Ecto.Migration

  def change do
    create table(:torrent_files) do
      add :path, {:array, :string}
      add :size, :bigint
      add :torrent_id, references(:torrents, on_delete: :delete_all)

      timestamps()
    end

    create index(:torrent_files, [:torrent_id])
  end
end
