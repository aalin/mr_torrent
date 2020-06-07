defmodule MrTorrentWeb.TorrentChannel do
  use MrTorrentWeb, :channel

  @impl true
  def join("torrent:" <> id, payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end
end
