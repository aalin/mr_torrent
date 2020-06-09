defmodule MrTorrentWeb.TorrentChannel do
  use MrTorrentWeb, :channel

  @impl true
  def join("torrent:" <> id, _payload, socket) do
    if MrTorrent.Torrents.torrent_exists?(id) do
      {:ok, socket}
    else
      {:error, "Torrent does not exist"}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end
end
