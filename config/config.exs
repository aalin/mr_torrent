# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mr_torrent,
  ecto_repos: [MrTorrent.Repo]

# Configures the endpoint
config :mr_torrent, MrTorrentWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hlVPmK7EmHgpjK1jFZtQA0GBB9ohj7/ukgA/303DJbJnBIkWNqcKZdl3hzsld1To",
  render_errors: [view: MrTorrentWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MrTorrent.PubSub,
  live_view: [signing_salt: "syOuu/bx"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
