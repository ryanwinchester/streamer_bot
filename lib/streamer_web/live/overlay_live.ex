defmodule StreamerWeb.OverlayLive do
  use StreamerWeb, :live_view

  require Logger

  import StreamerWeb.EventComponents

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Streamer.subscribe("twitch:events")
    end

    socket =
      socket
      |> assign(:events, [])

    {:ok, socket}
  end

  @impl true
  def handle_info({:twitch, %TwitchEventSub.Events.Follow{} = event}, socket) do
    id = :erlang.phash2(event)
    Process.send_after(self(), {:remove_event, id}, 4_000)

    video =
      Enum.random([
        "hello-joe.webm",
        "hello-mike.webm",
        "hello-robert.webm"
      ])

    socket =
      socket
      |> assign(:video, video)
      |> update(:events, &[{id, event} | &1])

    {:noreply, socket}
  end

  def handle_info({:twitch, event}, socket) do
    id = :erlang.phash2(event)
    Process.send_after(self(), {:remove_event, id}, 10_000)
    {:noreply, update(socket, :events, &[{id, event} | &1])}
  end

  def handle_info({:remove_event, id}, socket) do
    {:noreply, update(socket, :events, &List.keydelete(&1, id, 0))}
  end
end
