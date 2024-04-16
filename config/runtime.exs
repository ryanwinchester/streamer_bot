import Config

# Twitch Chat
config :streamer,
  bot: [
    bot: Streamer.TwitchChatBot,
    user: System.fetch_env!("TWITCH_USER"),
    pass: System.fetch_env!("TWITCH_OAUTH_TOKEN"),
    channels: [System.fetch_env!("TWITCH_USER")]
  ]

twitch_access_token =
  case config_env() do
    :prod ->
      access_token = System.fetch_env!("TWITCH_ACCESS_TOKEN")

    _ ->
      File.read!(".twitch.json") |> Jason.decode!() |> Map.fetch!("access_token")
  end

# Twitch EventSub
config :streamer, TwitchEventSub,
  broadcaster_user_id: System.fetch_env!("TWITCH_USER_ID"),
  user_id: System.fetch_env!("TWITCH_USER_ID"),
  channel_ids: [System.fetch_env!("TWITCH_USER_ID")],
  handler: Streamer.TwitchEventHandler,
  client_id: System.fetch_env!("TWITCH_CLIENT_ID"),
  client_secret: System.fetch_env!("TWITCH_CLIENT_SECRET"),
  access_token: twitch_access_token,
  # TODO: Add channel.chat.message later.
  subscriptions: ~w[
      channel.chat.notification
      channel.ad_break.begin channel.cheer channel.follow channel.subscription.end
      channel.channel_points_custom_reward_redemption.add
      channel.channel_points_custom_reward_redemption.update
      channel.charity_campaign.donate channel.charity_campaign.progress
      channel.goal.begin channel.goal.progress channel.goal.end
      channel.hype_train.begin channel.hype_train.progress channel.hype_train.end
      channel.shoutout.create channel.shoutout.receive
      stream.online stream.offline
  ]

# Spotify API
config :streamer, Streamer.SpotifyClient,
  client_id: System.fetch_env!("SPOTIFY_CLIENT_ID"),
  client_secret: System.fetch_env!("SPOTIFY_CLIENT_SECRET"),
  refresh_token: System.fetch_env!("SPOTIFY_REFRESH_TOKEN")

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/streamer start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :streamer, StreamerWeb.Endpoint, server: true
end

if config_env() == :prod do
  # Twitch EventSub
  config :streamer, TwitchEventSub, access_token: System.fetch_env!("TWITCH_ACCESS_TOKEN")

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :streamer, Streamer.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :streamer, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :streamer, StreamerWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :streamer, StreamerWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :streamer, StreamerWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
