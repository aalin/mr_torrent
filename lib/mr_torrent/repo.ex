defmodule MrTorrent.Repo do
  use Ecto.Repo,
    otp_app: :mr_torrent,
    adapter: Ecto.Adapters.Postgres
end
