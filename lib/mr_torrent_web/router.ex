defmodule MrTorrentWeb.Router do
  use MrTorrentWeb, :router

  import MrTorrentWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :torrent_client do
    plug :accepts, ["*/*"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_layout, {MrTorrentWeb.Admin.LayoutView, "app.html"}
  end

  scope "/", MrTorrentWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", SessionController, :new
    get "/signup", SignupController, :new
    post "/signup", SignupController, :create
  end

  scope "/", MrTorrentWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/browse", TorrentController, :index
    get "/torrents/:slug", TorrentController, :show
    get "/download/:slug", TorrentController, :download
    get "/upload", TorrentController, :new
    post "/torrents", TorrentController, :create
  end

  scope "/admin", MrTorrentWeb, as: :admin do
    pipe_through [
      :browser,
      :require_authenticated_user,
      :require_admin_user,
      :admin
    ]

    get "/", Admin.DashboardController, :index
    get "/users", Admin.UserController, :index
  end

  scope "/", MrTorrentWeb do
    pipe_through [:browser]

    get "/session", SessionController, :index
    post "/session", SessionController, :create
    delete "/session", SessionController, :delete
  end

  scope "/", MrTorrentWeb do
    pipe_through [:torrent_client]

    get "/announce/:token", TorrentController, :announce
  end

  # Other scopes may use custom stacks.
  # scope "/api", MrTorrentWeb do
  #   pipe_through :api
  # end
  #

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MrTorrentWeb.Telemetry
    end
  end
end
