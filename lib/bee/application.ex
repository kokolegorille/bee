defmodule Bee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BeeWeb.Telemetry,
      # Start the Ecto repository
      Bee.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bee.PubSub},
      # Start Finch
      {Finch, name: Bee.Finch},
      # Start the Endpoint (http/https)
      BeeWeb.Endpoint
      # Start a worker by calling: Bee.Worker.start_link(arg)
      # {Bee.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bee.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
