defmodule MrTorrent.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :username, :citext, null: false
      add :email, :citext, null: false
      add :password_hash, :string, null: false
      add :admin, :boolean, null: false, default: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
