defmodule MrTorrent.AccountsTest do
  use MrTorrent.DataCase

  alias MrTorrent.Accounts

  describe "users" do
    alias MrTorrent.Accounts.User

    @valid_attrs %{username: "lunalisa", email: "foo@bar.com", password: "lunalisa1337"}
    @update_attrs %{username: "lunalisa", password: "lunalisa5555"}
    @invalid_attrs %{username: "x", email: "y", password: "z"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.register_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "register_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert String.length(user.password_hash) == 60
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
