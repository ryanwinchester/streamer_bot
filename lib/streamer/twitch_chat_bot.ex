defmodule Streamer.TwitchChatBot do
  @moduledoc """
  SpotifyBot is a Twitch chat bot for adding songs to a Spotify play queue.
  """
  use TwitchChat.Bot

  alias Streamer.SpotifyClient

  alias TwitchChat.Events.Message

  require Logger

  @impl true
  def handle_event(%Message{message: "!ide", channel: channel, display_name: user}) do
    say(channel, "#{user}, I'm mostly using Zed lately (https://zed.dev)")
  end

  def handle_event(%Message{message: "!song link", channel: channel, display_name: user}) do
    case SpotifyClient.get_current_track!() do
      %{"is_playing" => true, "item" => track} ->
        %{"external_urls" => %{"spotify" => url}} = track
        say(channel, url)

      _track ->
        say(channel, "@#{user} nothing is playing")
    end
  end

  def handle_event(%Message{message: "!song", channel: channel, display_name: user}) do
    case SpotifyClient.get_current_track!() do
      %{"is_playing" => true, "item" => track} ->
        artists = Enum.map_join(track["artists"], ", ", & &1["name"])
        say(channel, "@#{user} currently playing 『#{artists} - #{track["name"]}』")

      _track ->
        say(channel, "@#{user} nothing is playing")
    end
  end

  def handle_event(event) do
    super(event)
    # Streamer.broadcast("twitch:events", {:twitch, event})
  end
end
