defmodule MrTorrent.Torrents.Torrent do
  use Ecto.Schema
  import Ecto.Changeset

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
  end

  def from_file(path, user) do
    {:ok, file} = File.read(path)
    {:ok, %{"info" => info}} = Bencode.decode(file)

    name = Path.basename(info["name"])

    data = %{
      slug: info["name"],
      name: info["name"],
      files: parse_files(info),
      piece_length: info["piece length"],
      pieces: info["pieces"],
      user_id: user.id
    }

    {:ok, encoded} = generate_torrent_file(data, "announce url", "comment")
    {:ok, _, info_hash} = Bencode.decode_with_info_hash(encoded)

    %MrTorrent.Torrents.Torrent{}
    |> changeset(data |> Map.put(:info_hash, info_hash))
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

  defp parse_file(%{"length" => length, "name" => name}) do
    %{length: length, name: name}
  end
end
