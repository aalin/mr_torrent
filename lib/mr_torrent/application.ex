defmodule MrTorrent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MrTorrent.Repo,
      # Start the Telemetry supervisor
      MrTorrentWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MrTorrent.PubSub},
      # Start the Endpoint (http/https)
      MrTorrentWeb.Endpoint,
      # Start a worker by calling: MrTorrent.Worker.start_link(arg)
      # {MrTorrent.Worker, arg}
      MrTorrent.Peerlist.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MrTorrent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MrTorrentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
