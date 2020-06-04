defmodule MrTorrent.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MrTorrent.Repo

  alias MrTorrent.Accounts.User
  alias MrTorrent.Accounts.UserSession

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_username_and_password(username, password)
  when is_binary(username) and is_binary(password) do
    user = Repo.get_by(User, username: username)
    if User.valid_password?(user, password), do: user
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.signup_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def change_user_signup(%User{} = user, attrs \\ %{}) do
    User.signup_changeset(user, attrs)
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def create_user_session(user) do
    {token, user_session} = UserSession.generate_token(user)
    Repo.insert!(user_session)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserSession.verify_token_query(token)
    Repo.one(query)
  end

  def delete_user_session(token) do
    Repo.delete_all(UserSession.token_query(token))
    :ok
  end
end
