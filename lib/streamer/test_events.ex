defmodule Streamer.TestEvents do
  @moduledoc """
  Generate test events.
  """

  @doc """
  Broadcast an event.
  """
  def broadcast(type, event) do
    Streamer.broadcast("twitch:events", {:twitch, type, event})
  end

  # ----------------------------------------------------------------------------
  # Events
  # ----------------------------------------------------------------------------

  def cheer(overrides \\ %{}) do
    %{
      "bits" => 100
    }
    |> Map.merge(Map.new(overrides))
  end

  def follow(overrides \\ %{}) do
    %{
      #
    }
    |> Map.merge(Map.new(overrides))
  end

  def raid(overrides \\ %{}) do
    %{
      #
    }
    |> Map.merge(Map.new(overrides))
  end
end
