defmodule MrTorrent.Torrents.Access do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  @rand_size 32

  schema "accesses" do
    field :token, :binary
    belongs_to :torrent, MrTorrent.Torrents.Torrent
    belongs_to :user, MrTorrent.Accounts.User

    timestamps()
  end

  def generate_access(torrent, user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    %MrTorrent.Torrents.Access{token: token, torrent_id: torrent.id, user_id: user.id}
  end

  def find_for_torrent_and_user_query(torrent, user) do
    query =
      from access in MrTorrent.Torrents.Access,
        where: [torrent_id: ^torrent.id, user_id: ^user.id]

    {:ok, query}
  end

  def verify_token_query(token) do
    query =
      from access in MrTorrent.Torrents.Access,
        where: [token: ^token],
        join: user in assoc(access, :user),
        join: torrent in assoc(access, :torrent),
        select: [access, user, torrent]

    {:ok, query}
  end

  def download_count_query(torrent) do
    from access in MrTorrent.Torrents.Access,
      where: [torrent_id: ^torrent.id],
      select: count(access.id)
  end

  def encode_token(token), do: Base.encode16(token)
  def decode_token(token), do: Base.decode16(token)
end
