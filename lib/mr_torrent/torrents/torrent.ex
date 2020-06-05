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

    data = %{
      name: info["name"],
      files: parse_files(info),
      piece_length: info["piece length"],
      pieces: info["pieces"],
      user_id: user.id
    }

    {:ok, encoded} = generate_torrent_file(data, "", "")

    {:ok, _, info_hash} = Bencode.decode_with_info_hash(encoded)

    data = Map.put(data, :info_hash, info_hash)

    changeset(%MrTorrent.Torrents.Torrent{}, data)
  end

  def generate_torrent_file(data, announce_url, comment) do
    Bencode.encode(%{
      "announce" => announce_url,
      "comment" => comment,
      "info" => generate_info(data)
    })
  end

  defp generate_info(data) do
    if Enum.count(data.files) == 1 do
      %{
        "name" => data.name,
        "length" => List.first(data.files).length,
        "piece length" => data.piece_length,
        "pieces" => data.pieces,
        "private" => 1
      }
    else
      %{
        "name" => data.name,
        "files" => data.files,
        "piece length" => data.piece_length,
        "pieces" => data.pieces,
        "private" => 1
      }
    end
  end

  defp parse_files(%{"files" => files})
  when is_list(files) do
    Enum.map(files, &parse_file/1)
  end

  defp parse_files(info) do
    [%{length: info["length"], name: info["name"]}]
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
