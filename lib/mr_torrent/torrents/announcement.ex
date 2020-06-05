defmodule MrTorrent.Torrents.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcements" do
    field :downloaded, :integer
    field :left, :integer
    field :uploaded, :integer
    field :event, :string
    field :ip, :string
    field :port, :integer

    belongs_to :access, MrTorrent.Torrents.Access

    timestamps()
  end

  def generate(ip, access, params) do
    %MrTorrent.Torrents.Announcement{}
    |> cast(params, [:downloaded, :uploaded, :left, :ip, :port, :event])
    |> put_change(:ip, to_string(:inet_parse.ntoa(ip)))
    |> put_change(:access_id, access.id)
    |> validate_required([:downloaded, :uploaded, :left, :ip, :port, :event])
  end
end
