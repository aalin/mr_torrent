defmodule MrTorrent.AccountsFixtures do
  defp random_hash(length), do: :crypto.strong_rand_bytes(length) |> Base.encode16()

  def unique_username, do: "user#{random_hash(5)}"
  def unique_user_email, do: "user#{random_hash(5)}@example.com"
  def valid_user_password, do: "yoloswag1337"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: unique_username(),
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> MrTorrent.Accounts.register_user()

    user
  end

  def admin_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      MrTorrent.Accounts.User.update_changeset(
        %MrTorrent.Accounts.User{admin: true},
        %{
          username: unique_username(),
          email: unique_user_email(),
          password: valid_user_password()
        }
      )
      |> MrTorrent.Repo.insert()

    user
  end
end
