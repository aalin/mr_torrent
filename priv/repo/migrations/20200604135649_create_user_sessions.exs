defmodule MrTorrent.Repo.Migrations.CreateUserSessions do
  use Ecto.Migration

  def change do
    create table(:user_sessions) do
      add :user_id, references(:users, on_delete: :nothing)
      add :token, :binary

      timestamps()
    end

    create unique_index(:user_sessions, [:token])
  end
end
