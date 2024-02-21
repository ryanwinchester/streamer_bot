defmodule Streamer do
  @moduledoc """
  Streamer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Streamer.PubSub, topic)
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(Streamer.PubSub, topic, message)
  end
end
