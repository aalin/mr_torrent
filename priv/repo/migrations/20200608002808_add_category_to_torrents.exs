defmodule MrTorrent.Repo.Migrations.AddCategoryToTorrents do
  use Ecto.Migration

  def change do
    alter table(:torrents) do
      add :category_id, :integer, null: false
    end
  end
end
