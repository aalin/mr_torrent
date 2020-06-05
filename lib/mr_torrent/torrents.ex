defmodule MrTorrent.Torrents do
  alias MrTorrent.Repo

  alias MrTorrent.Torrents.Torrent
  alias MrTorrent.Torrents.Access
  alias MrTorrent.Torrents.Announcement

  def list_torrents do
    Repo.all(Torrent)
  end

  def get_torrent!(id), do: Repo.get!(Torrent, id)
  def get_torrent_by_slug!(slug), do: Repo.get_by!(Torrent, slug: slug)

  def create_torrent(%Plug.Upload{path: path}, %MrTorrent.Accounts.User{} = user) do
    Torrent.create_from_file(path, user)
    |> Repo.insert
  end

  def delete_torrent(%Torrent{} = torrent) do
    Repo.delete(torrent)
  end

  def generate_torrent_for_user(conn, %Torrent{} = torrent, user) do
    access = find_or_create_access(torrent, user)

    announce_url = "#{conn.scheme}://#{conn.host}:#{conn.port}/announce/#{Access.encode_token(access.token)}"
    comment = "MrTorrent Tracker"

    Torrent.generate_torrent_file(torrent, announce_url, comment)
  end

  defp find_or_create_access(torrent, user) do
    {:ok, query} = Access.find_for_torrent_and_user_query(torrent, user)

    if access = Repo.one(query) do
      access
    else
      Access.generate_access(torrent, user)
      |> Repo.insert!()
    end
  end

  def announce(ip, token, params) do
    {:ok, raw_token} = Access.decode_token(token)
    {:ok, query} = Access.verify_token_query(raw_token)

    if [access, _user, torrent] = Repo.one(query) do
      # TODO: Check if user is still active
      Announcement.generate(ip, access, params)
      |> Repo.insert!()
      {:ok, build_peerlist(torrent)}
    else
      {:error, "Coult not verify token"}
    end
  end

  @announce_interval 60 * 5

  defp build_peerlist(torrent) do
    peers = []
    %{interval: @announce_interval, peers: peers}
  end
end
