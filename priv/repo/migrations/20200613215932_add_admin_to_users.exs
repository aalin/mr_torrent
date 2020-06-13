defmodule MrTorrent.Repo.Migrations.AddAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_id, :boolean, default: false, null: false
    end
  end
end
