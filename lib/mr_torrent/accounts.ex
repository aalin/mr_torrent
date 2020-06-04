defmodule MrTorrent.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MrTorrent.Repo

  alias MrTorrent.Accounts.User
  alias MrTorrent.Accounts.UserSession

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  alias MrTorrent.Accounts.UserSession

  @doc """
  Returns the list of user_sessions.

  ## Examples

      iex> list_user_sessions()
      [%UserSession{}, ...]

  """
  def list_user_sessions do
    Repo.all(UserSession)
  end

  @doc """
  Gets a single user_session.

  Raises `Ecto.NoResultsError` if the User session does not exist.

  ## Examples

      iex> get_user_session!(123)
      %UserSession{}

      iex> get_user_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_session!(id), do: Repo.get!(UserSession, id)

  @doc """
  Creates a user_session.

  ## Examples

      iex> create_user_session(%{field: value})
      {:ok, %UserSession{}}

      iex> create_user_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_session(user) do
    {token, user_session} = UserSession.generate_token(user)
    Repo.insert!(user_session)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserSession.verify_token_query(token)
    Repo.one(query)
  end

  def delete_user_session(%UserSession{} = user_session) do
    Repo.delete(user_session)
  end
end
