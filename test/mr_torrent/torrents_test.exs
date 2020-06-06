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

    test "create_torrent/2 with a valid torrent creates it" do
      assert {:ok, %Torrent{} = torrent} = MrTorrent.Torrents.create_torrent(
        valid_torrent_upload(),
        user_fixture()
      )

      assert torrent.name == "debian-10.4.0-amd64-netinst.iso"
      assert torrent.files == [
        %{length: 352321536, path: ["debian-10.4.0-amd64-netinst.iso"]}
      ]
      assert torrent.piece_length == 1024 * 256
    end

    test "create_torrent/2 with invalid data returns error changeset" do
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
    setup do
      %{
        torrent: torrent_fixture(),
        user: user_fixture()
      }
    end

    test "generate_torrent_for_user/3 returns a torrent file", %{torrent: torrent, user: user} do
      conn = %Plug.Conn{scheme: :https, host: "mrtracker.local", port: 1234}

      {:ok, torrent_file} = Torrents.generate_torrent_for_user(conn, torrent, user)
      {:ok, decoded, info_hash} = Bencode.decode_with_info_hash(torrent_file)

      assert info_hash == torrent.info_hash
      assert String.starts_with?(decoded["announce"], "https://mrtracker.local:1234/announce/")
      assert decoded["info"]["length"] == 352321536
      assert decoded["info"]["private"] == 1
    end

    test "generate_torrent_for_user/3 creates only one access per user", %{torrent: torrent, user: user} do
      conn = %Plug.Conn{scheme: :https, host: "mrtracker.local"}

      assert Torrents.download_count(torrent) == 0

      {:ok, _torrent_file} = Torrents.generate_torrent_for_user(conn, torrent, user)
      assert Torrents.download_count(torrent) == 1

      {:ok, _torrent_file} = Torrents.generate_torrent_for_user(conn, torrent, user)
      assert Torrents.download_count(torrent) == 1
    end
  end

  describe "announcements" do
    @valid_params %{downloaded: 0, uploaded: 0, left: 0, port: 1234, event: "started"}

    setup do
      torrent = torrent_fixture()
      user = user_fixture()
      access = Torrents.find_or_create_access(torrent, user)

      %{
        torrent: torrent,
        user: user,
        access: access
      }
    end

    test "announce/3 returns a peer list", %{ access: access} do
      {:ok, response} = Torrents.announce(
        {192, 168, 0, 1},
        Torrents.Access.encode_token(access.token),
        @valid_params
      )

      assert response.interval == 300
      assert response.peers == []
    end

    test "announce/3 returns an error if the token is invalid" do
      {:error, error} = Torrents.announce(
        {192, 168, 0, 1},
        "invalid",
        @valid_params
      )

      assert error == "Could not verify token"
    end

    @tag :pending
    test "announce/3 returns an error if the user does not exist"
  end
end
