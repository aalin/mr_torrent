defmodule MrTorrent.Torrents do
  alias MrTorrent.Repo

  alias MrTorrent.Torrents.Torrent

  def list_torrents do
    Repo.all(Torrent)
  end

  def get_torrent!(id), do: Repo.get!(Torrent, id)
  def get_torrent_by_slug!(slug), do: Repo.get_by!(Torrent, slug: slug)

  def create_torrent(%Plug.Upload{path: path}, %MrTorrent.Accounts.User{} = user) do
    Torrent.from_file(path, user)
    |> Repo.insert
  end

  def delete_torrent(%Torrent{} = torrent) do
    Repo.delete(torrent)
  end
end
