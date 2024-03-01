defmodule Streamer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StreamerWeb.Telemetry,
      Streamer.Repo,
      {DNSCluster, query: Application.get_env(:streamer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Streamer.PubSub},
      # Start a worker by calling: Streamer.Worker.start_link(arg)
      # {Streamer.Worker, arg},
      # Start to serve requests, typically the last entry
      StreamerWeb.Endpoint,
      Streamer.SongPoller,
      {Streamer.SongQueue, Application.get_env(:streamer, Streamer.SongQueue, [])},
      {TwitchChat.Supervisor, Application.fetch_env!(:streamer, :bot)},
      {TwitchEventSub.Supervisor, Application.fetch_env!(:streamer, TwitchEventSub)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Streamer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StreamerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
