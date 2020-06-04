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
end