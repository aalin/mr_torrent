defmodule MrTorrent.TorrentsTest do
  use MrTorrent.DataCase

  alias MrTorrent.Torrents

  describe "torrents" do
    alias MrTorrent.Torrents.Torrent

    @valid_attrs %{files: [], name: "some name", piece_length: 42, pieces: "some pieces"}
    @update_attrs %{files: [], name: "some updated name", piece_length: 43, pieces: "some updated pieces"}
    @invalid_attrs %{files: nil, name: nil, piece_length: nil, pieces: nil}

    def torrent_fixture(attrs \\ %{}) do
      {:ok, torrent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Torrents.create_torrent()

      torrent
    end

#    test "list_torrents/0 returns all torrents" do
#      torrent = torrent_fixture()
#      assert Torrents.list_torrents() == [torrent]
#    end

#    test "get_torrent!/1 returns the torrent with given id" do
#      torrent = torrent_fixture()
#      assert Torrents.get_torrent!(torrent.id) == torrent
#    end

#    test "create_torrent/1 with valid data creates a torrent" do
#      assert {:ok, %Torrent{} = torrent} = Torrents.create_torrent(file)
#      assert torrent.files == []
#      assert torrent.name == "some name"
#      assert torrent.piece_length == 42
#      assert torrent.pieces == "some pieces"
#    end
#
#    test "create_torrent/1 with invalid data returns error changeset" do
#      assert {:error, %Ecto.Changeset{}} = Torrents.create_torrent(@invalid_attrs)
#    end
#
#    test "update_torrent/2 with valid data updates the torrent" do
#      torrent = torrent_fixture()
#      assert {:ok, %Torrent{} = torrent} = Torrents.update_torrent(torrent, @update_attrs)
#      assert torrent.files == []
#      assert torrent.name == "some updated name"
#      assert torrent.piece_length == 43
#      assert torrent.pieces == "some updated pieces"
#    end
#
#    test "delete_torrent/1 deletes the torrent" do
#      torrent = torrent_fixture()
#      assert {:ok, %Torrent{}} = Torrents.delete_torrent(torrent)
#      assert_raise Ecto.NoResultsError, fn -> Torrents.get_torrent!(torrent.id) end
#    end
  end

  describe "accesses" do
    alias MrTorrent.Torrents.Access

    @valid_attrs %{token: "some token"}
    @update_attrs %{token: "some updated token"}
    @invalid_attrs %{token: nil}

    def access_fixture(attrs \\ %{}) do
      {:ok, access} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Torrents.create_access()

      access
    end

    test "list_accesses/0 returns all accesses" do
      access = access_fixture()
      assert Torrents.list_accesses() == [access]
    end

    test "get_access!/1 returns the access with given id" do
      access = access_fixture()
      assert Torrents.get_access!(access.id) == access
    end

    test "create_access/1 with valid data creates a access" do
      assert {:ok, %Access{} = access} = Torrents.create_access(@valid_attrs)
      assert access.token == "some token"
    end

    test "create_access/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Torrents.create_access(@invalid_attrs)
    end

    test "update_access/2 with valid data updates the access" do
      access = access_fixture()
      assert {:ok, %Access{} = access} = Torrents.update_access(access, @update_attrs)
      assert access.token == "some updated token"
    end

    test "update_access/2 with invalid data returns error changeset" do
      access = access_fixture()
      assert {:error, %Ecto.Changeset{}} = Torrents.update_access(access, @invalid_attrs)
      assert access == Torrents.get_access!(access.id)
    end

    test "delete_access/1 deletes the access" do
      access = access_fixture()
      assert {:ok, %Access{}} = Torrents.delete_access(access)
      assert_raise Ecto.NoResultsError, fn -> Torrents.get_access!(access.id) end
    end

    test "change_access/1 returns a access changeset" do
      access = access_fixture()
      assert %Ecto.Changeset{} = Torrents.change_access(access)
    end
  end

  describe "announcements" do
    alias MrTorrent.Torrents.Announcement

    @valid_attrs %{downloaded: 42, left: 42, uploaded: 42}
    @update_attrs %{downloaded: 43, left: 43, uploaded: 43}
    @invalid_attrs %{downloaded: nil, left: nil, uploaded: nil}

    def announcement_fixture(attrs \\ %{}) do
      {:ok, announcement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Torrents.create_announcement()

      announcement
    end

    test "list_announcements/0 returns all announcements" do
      announcement = announcement_fixture()
      assert Torrents.list_announcements() == [announcement]
    end

    test "get_announcement!/1 returns the announcement with given id" do
      announcement = announcement_fixture()
      assert Torrents.get_announcement!(announcement.id) == announcement
    end

    test "create_announcement/1 with valid data creates a announcement" do
      assert {:ok, %Announcement{} = announcement} = Torrents.create_announcement(@valid_attrs)
      assert announcement.downloaded == 42
      assert announcement.left == 42
      assert announcement.uploaded == 42
    end

    test "create_announcement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Torrents.create_announcement(@invalid_attrs)
    end

    test "update_announcement/2 with valid data updates the announcement" do
      announcement = announcement_fixture()
      assert {:ok, %Announcement{} = announcement} = Torrents.update_announcement(announcement, @update_attrs)
      assert announcement.downloaded == 43
      assert announcement.left == 43
      assert announcement.uploaded == 43
    end

    test "update_announcement/2 with invalid data returns error changeset" do
      announcement = announcement_fixture()
      assert {:error, %Ecto.Changeset{}} = Torrents.update_announcement(announcement, @invalid_attrs)
      assert announcement == Torrents.get_announcement!(announcement.id)
    end

    test "delete_announcement/1 deletes the announcement" do
      announcement = announcement_fixture()
      assert {:ok, %Announcement{}} = Torrents.delete_announcement(announcement)
      assert_raise Ecto.NoResultsError, fn -> Torrents.get_announcement!(announcement.id) end
    end

    test "change_announcement/1 returns a announcement changeset" do
      announcement = announcement_fixture()
      assert %Ecto.Changeset{} = Torrents.change_announcement(announcement)
    end
  end
end
