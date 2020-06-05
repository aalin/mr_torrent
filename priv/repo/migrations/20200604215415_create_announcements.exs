defmodule MrTorrent.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :downloaded, :integer, default: 0
      add :left, :integer, default: 0
      add :uploaded, :integer, default: 0
      add :ip, :string, null: false
      add :port, :integer, null: false
      add :event, :string, null: false
      add :access_id, references(:accesses, on_delete: :nothing)

      timestamps()
    end

    create index(:announcements, [:access_id])
  end
end
