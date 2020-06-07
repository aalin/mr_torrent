defmodule MrTorrent.Torrents.Torrent do
  defmodule TorrentFile do
    @behaviour Ecto.Type

    def type, do: :map
    def embed_as(_), do: :map
    def equal?(a, b), do: Map.equal?(a, b)

    def cast(map)
        when is_map(map) do
      {:ok, map}
    end

    def cast(_) do
      :error
    end

    def dump(map)
        when is_map(map) do
      result =
        for {key, val} <- map, into: %{} do
          if is_atom(key) do
            {Atom.to_string(key), val}
          else
            {key, val}
          end
        end

      {:ok, result}
    end

    def dump(_) do
      :error
    end

    def load(map)
        when is_map(map) do
      result =
        for {key, val} <- map, into: %{} do
          if is_atom(key) do
            {key, val}
          else
            {String.to_existing_atom(key), val}
          end
        end

      {:ok, result}
    end

    def load(_) do
      :error
    end
  end

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}

  schema "torrents" do
    field :name, :string
    field :slug, :string
    field :files, {:array, TorrentFile}
    field :piece_length, :integer
    field :pieces, :binary
    field :info_hash, :binary

    field :file, :string, virtual: true
    field :decoded_info, :map, virtual: true

    belongs_to :user, MrTorrent.Accounts.User

    timestamps()
  end

  def new_changeset(torrent, attrs \\ %{}) do
    change(torrent, attrs)
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
      |> validate_required([:name, :files, :piece_length, :pieces, :user_id])
      |> validate_length(:files, min: 1)
      |> validate_number(:piece_length, greater_than: 1)
      |> validate_length(:pieces, min: 1)
      |> unsafe_validate_unique(:info_hash, MrTorrent.Repo)
      |> unique_constraint(:info_hash)
      |> add_slug
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
        add_error(changeset, :file, message)
    end
  end

  defp set_fields_from_decoded_info(changeset) do
    decoded_info = get_change(changeset, :decoded_info)

    changeset
    |> put_change(:name, decoded_info["name"])
    |> put_change(:files, parse_files(decoded_info))
    |> put_change(:piece_length, decoded_info["piece length"])
    |> put_change(:pieces, decoded_info["pieces"])
    |> delete_change(:decoded_info)
  end

  defp set_info_hash(changeset) do
    case generate_torrent_file(changeset.changes, "", "") do
      {:ok, encoded} ->
        case Bencode.decode_with_info_hash(encoded) do
          {:ok, _, info_hash} ->
            put_change(changeset, :info_hash, info_hash)

          {:error, _error} ->
            add_error(changeset, :info_hash, "could not be calculated")
        end

      {:error, _error} ->
        add_error(changeset, :info_hash, "could not be calculated")
    end
  end

  def create_from_file(path, user) do
    torrent = %MrTorrent.Torrents.Torrent{}
    create_changeset(torrent, path, user)
  end

  defp decode_file(path) do
    with {:ok, file} <- File.read(path),
         {:ok, %{"info" => info}} <- Bencode.decode(file) do
      {:ok, info}
    end
  end

  def generate_torrent_file(data, announce_url, comment) do
    Bencode.encode(%{
      "announce" => announce_url,
      "comment" => comment,
      "info" => generate_torrent_info_data(data)
    })
  end

  defp generate_torrent_info_data(data) do
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
    [%{length: info["length"], path: [info["name"]]}]
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
