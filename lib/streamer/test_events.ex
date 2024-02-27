defmodule Streamer.TestEvents do
  @moduledoc """
  Generate test events.
  """

  @doc """
  Broadcast an event.
  """
  def broadcast(event) do
    Streamer.broadcast("twitch:events", {:twitch, event})
  end

  # ----------------------------------------------------------------------------
  # Events
  # ----------------------------------------------------------------------------

  def cheer(overrides \\ %{}) do
    %TwitchEventSub.Events.Cheer{
      bits: 100
    }
    |> Map.merge(Map.new(overrides))
  end

  def follow(overrides \\ %{}) do
    %TwitchEventSub.Events.Follow{
      #
    }
    |> Map.merge(Map.new(overrides))
  end

  def raid(overrides \\ %{}) do
    %TwitchChat.Events.Raid{
      #
    }
    |> Map.merge(Map.new(overrides))
  end
end
