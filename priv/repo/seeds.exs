# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MrTorrent.Repo.insert!(%MrTorrent.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

IO.puts("Creating movie categories")

movies = MrTorrent.Repo.insert!(%MrTorrent.Torrents.Category{name: "Movies"})

["Feature films", "Sci-fi / horror", "Comedy", "Silent movies", "Noir"]
|> Enum.each(fn name ->
  MrTorrent.Repo.insert!(%MrTorrent.Torrents.Category{name: name, parent_id: movies.id})
end)

IO.puts("Creating music categories")

music = MrTorrent.Repo.insert!(%MrTorrent.Torrents.Category{name: "Music"})

["Live concert", "Rock", "Grateful Dead", "Reggae", "Jazz", "Hiphop"]
|> Enum.each(fn name ->
  MrTorrent.Repo.insert!(%MrTorrent.Torrents.Category{name: name, parent_id: music.id})
end)
