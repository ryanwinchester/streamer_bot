defmodule Streamer.TwitchChatBot do
  @moduledoc """
  SpotifyBot is a Twitch chat bot for adding songs to a Spotify play queue.
  """
  use TwitchChat.Bot

  alias Streamer.SongQueue
  alias Streamer.SpotifyClient

  alias TwitchChat.Events.Message

  @impl true
  def handle_event(%Message{message: "!spotify add " <> link} = event) do
    %{channel: channel, display_name: user} = event

    case link do
      "https://open.spotify.com/track" <> _ ->
        track = SpotifyClient.get_track!(link)
        artists = Enum.map_join(track["artists"], ", ", & &1["name"])

        case SongQueue.add(track["id"], user) do
          :ok -> say(channel, "@#{user} added 『#{artists} - #{track["name"]}』 to the queue")
          {:error, :max_total} -> say(channel, "@#{user} the queue is full")
          {:error, :max_per_user} -> say(channel, "@#{user} you can't add more songs")
          {:error, :no_consecutive} -> say(channel, "@#{user} you can't add two songs in a row")
        end

      _ ->
        say(channel, "@#{user} must be a single spotify track link")
    end
  end

  def handle_event(%Message{message: "!spotify song", channel: channel, display_name: user}) do
    case SpotifyClient.get_current_track!() do
      %{"is_playing" => true, "item" => track} ->
        artists = Enum.map_join(track["artists"], ", ", & &1["name"])
        say(channel, "@#{user} currently playing 『#{artists} - #{track["name"]}』")

      _track ->
        say(channel, "@#{user} nothing is playing")
    end
  end
end
