defmodule Pc3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Pc3Web.Telemetry,
      {DNSCluster, query: Application.get_env(:pc3, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pc3.PubSub},
      # Start a worker by calling: Pc3.Worker.start_link(arg)
      # {Pc3.Worker, arg},
      # Start to serve requests, typically the last entry
      Pc3Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pc3.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Pc3Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
