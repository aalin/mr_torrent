defmodule MrTorrentWeb.TorrentController do
  use MrTorrentWeb, :controller

  alias MrTorrent.Torrents
  alias MrTorrent.Torrents.Torrent

  def index(conn, _params) do
    torrents = Torrents.list_torrents()
    render(conn, "index.html", torrents: torrents)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"torrent" => %{"file" => file}}) do
    case Torrents.create_torrent(file, conn.assigns.current_user) do
      {:ok, torrent} ->
        conn
        |> put_flash(:info, "Torrent created successfully.")
        |> redirect(to: Routes.torrent_path(conn, :show, torrent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    torrent = Torrents.get_torrent!(id)
    render(conn, "show.html", torrent: torrent)
  end

  def delete(conn, %{"id" => id}) do
    torrent = Torrents.get_torrent!(id)
    {:ok, _torrent} = Torrents.delete_torrent(torrent)

    conn
    |> put_flash(:info, "Torrent deleted successfully.")
    |> redirect(to: Routes.torrent_path(conn, :index))
  end
end
