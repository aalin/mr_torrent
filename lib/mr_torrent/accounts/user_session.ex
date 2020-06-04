defmodule MrTorrent.Accounts.UserSession do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  @rand_size 32

  schema "user_sessions" do
    field :token, :binary
    belongs_to :user, MrTorrent.Accounts.User

    timestamps()
  end

  def generate_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %MrTorrent.Accounts.UserSession{token: token, user_id: user.id}}
  end

  def verify_token_query(token) do
    query = from session in MrTorrent.Accounts.UserSession,
      where: [token: ^token],
      join: user in assoc(session, :user),
      select: user

    {:ok, query}
  end
end
