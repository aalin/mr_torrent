defmodule MrTorrentWeb.TorrentController do
  use MrTorrentWeb, :controller

  alias MrTorrent.Torrents

  def index(conn, params) do
    torrents = Torrents.list_torrents(params)
    render(conn, "index.html", torrents: torrents)
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Torrents.new_torrent())
  end

  def create(conn, params) do
    case Torrents.create_torrent(params["torrent"], conn.assigns.current_user) do
      {:ok, torrent} ->
        conn
        |> put_flash(:info, "Torrent created successfully.")
        |> redirect(to: Routes.torrent_path(conn, :show, torrent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    torrent = Torrents.get_torrent_by_slug!(slug)
    user = MrTorrent.Accounts.get_user!(torrent.user_id)
    {seeders, leechers} = MrTorrent.Peerlist.get_seeders_and_leechers(torrent)
    render(conn, "show.html", torrent: torrent, user: user, seeders: seeders, leechers: leechers)
  end

  def download(conn, %{"slug" => slug}) do
    torrent = Torrents.get_torrent_by_slug!(slug)

    {:ok, torrent_file} =
      Torrents.generate_torrent_for_user(conn, torrent, conn.assigns.current_user)

    send_download(
      conn,
      {:binary, torrent_file},
      content_type: "application/x-bittorrent; charset=binary",
      filename: "#{torrent.name}.torrent"
    )
  end

  def delete(conn, %{"slug" => slug}) do
    torrent = Torrents.get_torrent_by_slug!(slug)
    {:ok, _torrent} = Torrents.delete_torrent(torrent)

    conn
    |> put_flash(:info, "Torrent deleted successfully.")
    |> redirect(to: Routes.torrent_path(conn, :index))
  end

  def announce(conn, params) do
    case Torrents.announce(conn.remote_ip, params["token"], params) do
      {:ok, response} ->
        text(conn, Bencode.encode!(response))

      {:error, error} ->
        text(conn, Bencode.encode!(%{"error reason" => error}))
    end
  end
end
