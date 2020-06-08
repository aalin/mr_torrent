defmodule MrTorrent.Repo.Migrations.AddCategoryToTorrents do
  use Ecto.Migration

  def change do
    alter table(:torrents) do
      add :category_id, references(:categories, on_delete: :nilify_all)
    end
  end
end
