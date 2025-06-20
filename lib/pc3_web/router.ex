defmodule Pc3Web.Router do
  use Pc3Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Pc3Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/", Pc3Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  # OpenAPI documentation viewers (must come before the general API forward)
  scope "/api" do
    pipe_through :browser

    # Swagger UI for API documentation
    forward "/swaggerui",
            OpenApiSpex.Plug.SwaggerUI,
            path: "/api/open_api",
            default_model_expand_depth: 4

    # Redoc UI for API documentation
    forward "/redoc",
            Redoc.Plug.RedocUI,
            spec_url: "/api/open_api"
  end

  # API routes
  scope "/api" do
    pipe_through :api

    # Forward to the Ash JSON API router
    forward "/", Pc3Web.ApiRouter
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pc3, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Pc3Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
