defmodule StreamerWeb.OverlayLive do
  use StreamerWeb, :live_view

  alias StreamerWeb.Live.Overlay.TimerLive

  require Logger

  import StreamerWeb.Overlay.EventComponents

  @empty_timer %{active?: false, title: "", tick: 0, total: 0}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Streamer.subscribe("twitch:events")
      Streamer.subscribe("songs:current")
    end

    socket =
      socket
      |> assign(:timer, @empty_timer)
      |> assign(:current_song, nil)
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

  def handle_info(
        {:twitch,
         %TwitchEventSub.Events.ChannelPointsRedemption{reward_title: "Vim mode"} = event},
        socket
      ) do
    id = :erlang.phash2(event)
    time = 5 * 60 * 1000

    Process.send_after(self(), {:timer_tick, 0, time, 1000}, 1000)

    socket =
      socket
      |> update(:events, &[{id, event} | &1])
      |> update(:timer, &%{&1 | active?: true, title: "VIM MODE", total: time, tick: time})

    {:noreply, socket}
  end

  def handle_info({:twitch, %TwitchEventSub.Events.Cheer{} = event}, socket) do
    id = :erlang.phash2(event)
    Process.send_after(self(), {:remove_event, id}, 10_000)

    socket =
      socket
      |> push_event("falling-items", %{count: event.bits, img_src: ~p"/overlay/images/bit.gif"})
      |> update(:events, &[{id, event} | &1])

    {:noreply, socket}
  end

  def handle_info({:twitch, %TwitchChat.Events.Raid{} = event}, socket) do
    id = :erlang.phash2(event)
    Process.send_after(self(), {:remove_event, id}, 10_000)

    socket =
      socket
      |> push_event("exploding-items", %{
        count: event.viewer_count,
        img_src: event.profile_image_url
      })
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

  def handle_info({:timer_tick, time, time, _interval}, socket) do
    {:noreply, assign(socket, :timer, @empty_timer)}
  end

  def handle_info({:timer_tick, time, total, interval}, socket) do
    Process.send_after(self(), {:timer_tick, time + interval, total, interval}, interval)
    {:noreply, update(socket, :timer, &%{&1 | tick: time})}
  end

  def handle_info({:current_song, song}, socket) do
    Logger.debug("CURRENT SONG: #{inspect(song)}")
    {:noreply, assign(socket, :current_song, song)}
  end
end
