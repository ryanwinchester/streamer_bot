defmodule Streamer.TwitchEventHandler do
  use TwitchEventSub

  @impl true
  def handle_event(event) do
    Streamer.broadcast("twitch:events", {:twitch, event})
  end
end
