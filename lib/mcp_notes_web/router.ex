defmodule McpNotesWeb.Router do
  use McpNotesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {McpNotesWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug AshAuthentication.Strategy.ApiKey.Plug,
      resource: McpNotes.Accounts.User,
      # if you want to require an api key to be supplied, set `required?` to true
      required?: false
  end

  pipeline :mcp do
    plug AshAuthentication.Strategy.ApiKey.Plug,
      resource: McpNotes.Accounts.User,
      # Use `required?: false` to allow unauthenticated
      # users to connect, for example if some tools
      # are publicly accessible.
      required?: false
  end

  # scope "/", McpNotesWeb do
  #   pipe_through :browser

  #   get "/", PageController, :home
  # end

  scope "/mcp" do
    pipe_through :mcp

    forward "/", AshAi.Mcp.Router,
      tools: [
        :list_projects,
        :list_notes,
        :list_notes_for_project,
        :add_project,
        :add_note_to_project,
        :delete_project,
        :delete_notes_for_project,
        :stats
      ],
      protocol_version_statement: "2024-11-05",
      otp_app: :mcp_notes
  end

  # Other scopes may use custom stacks.
  # scope "/api", McpNotesWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mcp_notes, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: McpNotesWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
