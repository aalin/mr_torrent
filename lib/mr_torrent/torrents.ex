defmodule MrTorrent.Torrents do
  alias MrTorrent.Repo

  alias MrTorrent.Torrents.Torrent
  alias MrTorrent.Torrents.Access
  alias MrTorrent.Torrents.Announcement
  alias MrTorrent.Peerlist

  def list_torrents do
    Repo.all(Torrent)
  end

  def get_torrent!(id), do: Repo.get!(Torrent, id)
  def get_torrent_by_slug!(slug), do: Repo.get_by!(Torrent, slug: slug)

  def new_torrent do
    Torrent.new_changeset(%Torrent{})
  end

  def create_torrent(%Plug.Upload{path: path}, %MrTorrent.Accounts.User{} = user) do
    Torrent.create_from_file(path, user)
    |> Repo.insert()
  end

  def delete_torrent(%Torrent{} = torrent) do
    Repo.delete(torrent)
  end

  def generate_torrent_for_user(%Plug.Conn{} = conn, %Torrent{} = torrent, user) do
    access = find_or_create_access(torrent, user)

    comment = "MrTorrent Tracker"

    Torrent.generate_torrent_file(
      torrent,
      announce_url(conn, access.token),
      comment
    )
  end

  def find_or_create_access(torrent, user) do
    {:ok, query} = Access.find_for_torrent_and_user_query(torrent, user)

    if access = Repo.one(query) do
      access
    else
      Access.generate_access(torrent, user)
      |> Repo.insert!()
    end
  end

  defp announce_url(%Plug.Conn{scheme: scheme, host: host, port: port}, token) do
    encoded_token = Access.encode_token(token)

    %URI{
      scheme: Atom.to_string(scheme),
      host: host,
      port: port,
      path: "/announce/#{encoded_token}"
    }
    |> URI.to_string()
  end

  def download_count(%Torrent{} = torrent) do
    Access.download_count_query(torrent)
    |> Repo.one()
  end

  @announce_interval 60 * 5

  def announce(ip, token, params) do
    case decode_and_verify_token(token) do
      {:ok, access, _user, torrent} ->
        # TODO: Check if user is still active
        Announcement.generate(ip, access, params)
        |> Repo.insert!()

        {:ok, peers} = Peerlist.announce(torrent, ip, params)

        {:ok, %{interval: @announce_interval, peers: peers}}

      {:error, message} ->
        {:error, message}
    end
  end

  defp decode_and_verify_token(token) do
    with {:ok, raw_token} <- Access.decode_token(token),
         {:ok, query} <- Access.verify_token_query(raw_token),
         [access, user, torrent] <- Repo.one(query) do
      {:ok, access, user, torrent}
    else
      _ ->
        {:error, "Could not verify token"}
    end
  end
end
