defmodule MrTorrent.Repo.Migrations.CreateTorrentTags do
  use Ecto.Migration

  def change do
    create table(:torrent_tags) do
      add :torrent_id, references(:torrents, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
    end

    create unique_index(:torrent_tags, [:torrent_id, :tag_id])
  end
end
