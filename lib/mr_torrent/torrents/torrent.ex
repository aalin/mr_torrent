defmodule MrTorrent.Torrents.Torrent do

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}

  schema "torrents" do
    field :name, :string
    field :slug, :string
    field :files, {:array, :map}
    field :piece_length, :integer
    field :pieces, :binary
    field :info_hash, :binary

    belongs_to :user, MrTorrent.Accounts.User

    timestamps()
  end

  def changeset(torrent, attrs) do
    IO.inspect(torrent)
    IO.inspect(attrs)
    torrent
    |> cast(attrs, [:name, :files, :piece_length, :pieces, :user_id])
    |> validate_required([:name, :files, :piece_length, :pieces, :user_id])
    |> unsafe_validate_unique(:info_hash, MrTorrent.Repo)
    |> unique_constraint(:info_hash)
    |> add_slug
    |> validate_required([:slug])
    |> unsafe_validate_unique(:slug, MrTorrent.Repo)
    |> unique_constraint(:slug)
  end

  def from_file(path, user) do
    {:ok, file} = File.read(path)
    {:ok, %{"info" => info}} = Bencode.decode(file)

    name = Path.basename(info["name"])

    data = %{
      name: info["name"],
      files: parse_files(info),
      piece_length: info["piece length"],
      pieces: info["pieces"],
      user_id: user.id
    }

    {:ok, encoded} = generate_torrent_file(data, "announce url", "comment")
    {:ok, _, info_hash} = Bencode.decode_with_info_hash(encoded)

    changeset(%MrTorrent.Torrents.Torrent{info_hash: info_hash}, data)
  end

  def generate_torrent_file(data, announce_url, comment) do
    Bencode.encode(%{
      announce: announce_url,
      comment: comment,
      info: %{
        name: data.name,
        files: data.files,
        piece_length: data.piece_length,
        pieces: data.pieces,
        private: 1
      }
    })
  end

  defp parse_files(%{"files" => files})
  when is_list(files) do
    Enum.map(files, &parse_file/1)
  end

  defp parse_files(file)
  when is_map(file) do
    [parse_file(file)]
  end

  defp parse_file(%{"length" => length, "path" => path}) do
    %{length: length, path: path}
  end

  defp add_slug(changeset) do
    slug =
      get_change(changeset, :name)
      |> String.normalize(:nfd)
      |> String.replace(~r/[^a-z0-9\(\)\[\]\._-]+/i, "-")

    changeset
    |> put_change(:slug, slug)
  end
end
