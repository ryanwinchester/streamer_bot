defmodule Streamer.TwitchEventHandler do
  use TwitchEventSub

  alias Streamer.SongQueue
  alias Streamer.SpotifyClient

  import Streamer.TwitchChatBot, only: [say: 2]

  require Logger

  @impl true
  def handle_event(
        "channel.channel_points_custom_reward_redemption.add" = type,
        %{"reward" => %{"title" => "Queue Spotify Song"}} = event
      ) do
    link = event["user_input"]
    user = event["user_name"]
    channel = event["broadcaster_user_login"]

    case link do
      "https://open.spotify.com/track" <> _ ->
        track = SpotifyClient.get_track!(link)
        artists = Enum.map_join(track["artists"], ", ", & &1["name"])

        case SongQueue.add(track, user) do
          :ok -> say(channel, "@#{user} added 『#{artists} - #{track["name"]}』 to the queue")
          {:error, :max_total} -> say(channel, "@#{user}, the queue is full")
          {:error, :max_per_user} -> say(channel, "@#{user}, you can't add more songs")
          {:error, :no_consecutive} -> say(channel, "@#{user}, you can't add two songs in a row")
          {:error, :poor_taste} -> say(channel, "@#{user}, sorry but you have poor taste")
        end

      _ ->
        say(channel, "@#{user} must be a single spotify track link")
    end

    Streamer.broadcast("twitch:events", {:twitch, type, event})
  end

  def handle_event(type, event) do
    Logger.debug("[EventHandler] broadcasting `#{type}`")
    Streamer.broadcast("twitch:events", {:twitch, type, event})
  end
end
