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

IO.puts("Creating default user")

MrTorrent.Accounts.User.update_changeset(
  %MrTorrent.Accounts.User{admin: true},
  %{
    username: "admin",
    email: "admin@localhost",
    password: "adminadminadmin"
  }
)
|> MrTorrent.Repo.insert!()

["Movies", "TV-Shows", "Music", "Books", "Applications", "Games", "Other"]
|> Enum.each(fn name ->
     MrTorrent.Repo.insert!(%MrTorrent.Torrents.Category{name: name})
   end)
