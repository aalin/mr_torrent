defmodule MrTorrent.TorrentsTest do
  use MrTorrent.DataCase

  import MrTorrent.TorrentsFixtures
  import MrTorrent.AccountsFixtures

  alias MrTorrent.Torrents

  describe "torrents" do
    alias MrTorrent.Torrents.Torrent

    test "list_torrents/0 returns all torrents" do
      torrent = torrent_fixture()
      assert Torrents.list_torrents() == [torrent]
    end

    test "get_torrent!/1 returns the torrent with given id" do
      torrent = torrent_fixture()
      assert Torrents.get_torrent!(torrent.id) == torrent
    end

    test "create_torrent/1 with a valid torrent creates it" do
      assert {:ok, %Torrent{} = torrent} = MrTorrent.Torrents.create_torrent(
        valid_torrent_upload(),
        user_fixture()
      )

      assert torrent.name == "The.Karate.Kid.1984.1080p.BluRay.x264-CiNEFiLE"
      assert torrent.files == [
        %{length: 2217940452, path: ["The.Karate.Kid.1984.1080p.BluRay.x264-CiNEFiLE"]}
      ]
      assert torrent.piece_length == 1024 * 256
    end

    test "create_torrent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MrTorrent.Torrents.create_torrent(
        invalid_torrent_upload(),
        user_fixture()
      )
    end

    test "delete_torrent/1 deletes the torrent" do
      torrent = torrent_fixture()
      assert {:ok, %Torrent{}} = Torrents.delete_torrent(torrent)
      assert_raise Ecto.NoResultsError, fn -> Torrents.get_torrent!(torrent.id) end
    end
  end

  describe "accesses" do
    #alias MrTorrent.Torrents.Access
  end

  describe "announcements" do
    #alias MrTorrent.Torrents.Announcement
  end
end
