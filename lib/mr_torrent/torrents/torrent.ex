defmodule MrTorrent.Torrents.Torrent do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias MrTorrent.Torrents.TorrentFile

  @derive {Phoenix.Param, key: :slug}

  schema "torrents" do
    field :name, :string
    field :slug, :string
    field :info, :binary
    field :info_hash, :binary
    field :total_size, :integer

    field :uploaded_file, :binary, virtual: true
    field :decoded_info, :map, virtual: true

    belongs_to :user, MrTorrent.Accounts.User
    has_many :files, MrTorrent.Torrents.TorrentFile

    timestamps()
  end

  def find_torrent_query(id) do
    from torrent in MrTorrent.Torrents.Torrent,
      where: [id: ^id],
      preload: :files
  end

  def find_torrent_by_slug_query(slug) do
    from torrent in MrTorrent.Torrents.Torrent,
      where: [slug: ^slug],
      preload: :files
  end

  def generate_torrent_file(torrent, announce_url, comment) do
    Bencode.encode(%{
      "announce" => announce_url,
      "comment" => comment,
      "info" => Bencode.decode!(torrent.info),
    })
  end

  def new_changeset(torrent, attrs \\ %{}) do
    change(torrent, attrs)
  end

  def create_from_file(path, user) do
    torrent = %MrTorrent.Torrents.Torrent{}
    create_changeset(torrent, path, user)
  end

  def create_changeset(torrent, path, user) do
    changeset =
      change(torrent)
      |> put_change(:user_id, user.id)
      |> decode_and_validate_file(path)

    if changeset.valid? do
      changeset
      |> set_fields_from_decoded_info
      |> set_info_hash
      |> add_slug
      |> validate_required([:name, :slug, :info, :info_hash, :user_id])
      |> validate_length(:files, min: 1)
      |> unsafe_validate_unique(:info_hash, MrTorrent.Repo)
      |> unique_constraint(:info_hash)
      |> validate_required([:slug])
      |> unsafe_validate_unique(:slug, MrTorrent.Repo)
      |> unique_constraint(:slug)
    else
      changeset
    end
  end

  defp decode_and_validate_file(changeset, path) do
    case decode_file(path) do
      {:ok, info} ->
        put_change(changeset, :decoded_info, info)

      {:error, message} ->
        add_error(changeset, :uploaded_file, message)
    end
  end

  defp set_fields_from_decoded_info(changeset) do
    decoded_info = get_change(changeset, :decoded_info)

    {:ok, new_info} = Map.put(decoded_info, "private", 1) |> Bencode.encode

    parsed_files = parse_files(decoded_info)
    total_size = Enum.reduce(parsed_files, 0, fn (file, acc) -> file.size + acc end)

    changeset
    |> put_change(:name, decoded_info["name"])
    |> put_change(:info, new_info)
    |> put_assoc(:files, parsed_files)
    |> put_change(:total_size, total_size)
    |> delete_change(:decoded_info)
  end

  defp set_info_hash(changeset) do
    info = get_change(changeset, :info)

    put_change(changeset, :info_hash, :crypto.hash(:sha, info))
  end

  defp decode_file(path) do
    with {:ok, file} <- File.read(path),
         {:ok, %{"info" => info}} <- Bencode.decode(file) do
      {:ok, info}
    end
  end

  defp parse_files(%{"files" => files})
       when is_list(files) do
    Enum.map(files, &parse_file/1)
  end

  defp parse_files(info) do
    [%TorrentFile{size: info["length"], path: [info["name"]]}]
  end

  defp parse_file(%{"length" => length, "path" => path}) do
    %TorrentFile{size: length, path: path}
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
