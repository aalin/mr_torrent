defmodule MrTorrent.TorrentsFixtures do
  import MrTorrent.AccountsFixtures

  def valid_torrent_upload do
    path = "test/support/fixtures/debian-10.4.0-amd64-netinst.iso.torrent"
    %Plug.Upload{path: path, filename: Path.basename(path)}
  end

  def invalid_torrent_upload do
    path = "test/support/fixtures/invalid.torrent"
    %Plug.Upload{path: path, filename: Path.basename(path)}
  end

  def torrent_fixture(opts \\ %{}) do
    {:ok, torrent} =
      MrTorrent.Torrents.create_torrent(
        Map.get(opts, :upload) || valid_torrent_upload(),
        Map.get(opts, :user) || user_fixture()
      )

    torrent
  end
end
