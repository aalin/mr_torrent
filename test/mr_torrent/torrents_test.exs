defmodule MrTorrent.TorrentsTest do
  use MrTorrent.DataCase

  import MrTorrent.TorrentsFixtures
  import MrTorrent.AccountsFixtures

  alias MrTorrent.Torrents

  describe "torrents" do
    alias MrTorrent.Torrents.Torrent

    test "list_torrents/0 returns all torrents" do
      torrent = torrent_fixture()
      assert Enum.map(Torrents.list_torrents(), fn t -> t.id end) == [torrent.id]
    end

    test "get_torrent!/1 returns the torrent with given id" do
      torrent = torrent_fixture()
      assert Torrents.get_torrent!(torrent.id) == torrent
    end

    test "create_torrent/2 with a valid torrent creates it" do
      assert {:ok, %Torrent{} = torrent} =
               MrTorrent.Torrents.create_torrent(
                 valid_torrent_upload(),
                 user_fixture()
               )

      assert torrent.name == "debian-10.4.0-amd64-netinst.iso"

      assert [
               %{size: 352_321_536, path: ["debian-10.4.0-amd64-netinst.iso"]}
             ] = torrent.files

      assert torrent.total_size == 352_321_536
    end

    test "create_torrent/2 with a valid multifile torrent creates it" do
      assert {:ok, %Torrent{} = torrent} =
               MrTorrent.Torrents.create_torrent(
                 valid_multifile_torrent_upload(),
                 user_fixture()
               )

      assert torrent.name == "gd1967-07-23.aud.sorochty.125462.flac16"

      assert [
               %{size: 56821, path: ["ATheDeadBook.jpg"]},
               %{size: 3339, path: ["ATheDeadBook_thumb.jpg"]},
               %{size: 67229, path: ["BFlexi-disc.jpg"]},
               %{size: 5630, path: ["BFlexi-disc_thumb.jpg"]},
               %{size: 61336, path: ["CNealCassadyMugshot.jpg"]},
               %{size: 3312, path: ["CNealCassadyMugshot_thumb.jpg"]},
               %{size: 20156, path: ["TranscriptOfNealCassadysRap.htm"]},
               %{size: 6898, path: ["__ia_thumb.jpg"]},
               %{size: 114, path: ["gd1967-07-23.aud.sorochty.125462.flac16.ffp"]},
               %{size: 116, path: ["gd1967-07-23.aud.sorochty.125462.flac16.md5"]},
               %{size: 3668, path: ["gd1967-07-23.aud.sorochty.125462.flac16_meta.xml"]},
               %{size: 118, path: ["gd67-07-23.aud.cassady.sorochty.flac16.md5"]},
               %{size: 2906, path: ["gd67-07-23.aud.cassady.sorochty.txt"]},
               %{size: 62_323_126, path: ["gd67-07-23d1t1.aud.flac"]},
               %{size: 17_641_472, path: ["gd67-07-23d1t1.aud.mp3"]},
               %{size: 8_968_304, path: ["gd67-07-23d1t1.aud.ogg"]},
               %{size: 11266, path: ["gd67-07-23d1t1.aud.png"]},
               %{size: 65_199_823, path: ["gd67-07-23d1t2.aud.flac"]},
               %{size: 15_015_424, path: ["gd67-07-23d1t2.aud.mp3"]},
               %{size: 7_807_069, path: ["gd67-07-23d1t2.aud.ogg"]},
               %{size: 11870, path: ["gd67-07-23d1t2.aud.png"]}
             ] = torrent.files

      assert torrent.total_size == 177_209_997
    end

    test "create_torrent/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               MrTorrent.Torrents.create_torrent(
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
      assert decoded["info"]["length"] == 352_321_536
      assert decoded["info"]["private"] == 1
    end

    test "generate_torrent_for_user/3 creates only one access per user", %{
      torrent: torrent,
      user: user
    } do
      conn = %Plug.Conn{scheme: :https, host: "mrtracker.local"}

      assert Torrents.download_count(torrent) == 0

      {:ok, _torrent_file} = Torrents.generate_torrent_for_user(conn, torrent, user)
      assert Torrents.download_count(torrent) == 1

      {:ok, _torrent_file} = Torrents.generate_torrent_for_user(conn, torrent, user)
      assert Torrents.download_count(torrent) == 1
    end
  end

  describe "announcements" do
    @valid_params %{
      "downloaded" => "0",
      "uploaded" => "0",
      "left" => "0",
      "port" => "6937",
      "event" => "started",
      "peer_id" => :crypto.strong_rand_bytes(5)
    }

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

    test "announce/3 returns a peer list", %{access: access} do
      {:ok, response} =
        Torrents.announce(
          {192, 168, 0, 1},
          Torrents.Access.encode_token(access.token),
          @valid_params
        )

      assert response.interval == 300

      assert response.peers == [
               %{
                 ip: '192.168.0.1',
                 peer_id: URI.encode(@valid_params["peer_id"]),
                 port: 6937
               }
             ]
    end

    test "announce/3 returns an error if the token is invalid" do
      {:error, error} =
        Torrents.announce(
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
