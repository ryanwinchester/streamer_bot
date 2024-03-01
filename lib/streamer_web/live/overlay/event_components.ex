defmodule StreamerWeb.Overlay.EventComponents do
  @moduledoc """
  Event components.
  """
  use StreamerWeb, :verified_routes
  use Phoenix.Component

  alias TwitchEventSub.Events

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :event, :map, required: true

  def twitch_event(%{event: %Events.ChannelPointsRedemption{reward_title: "first"}} = assigns) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <%!-- <video class="absolute" src={~p"/overlay/videos/#{@video}"} autoplay="true" /> --%>
        <audio src={~p"/overlay/audio/yippee.mp3"} autoplay="true" />
        <span class="absolute text-center text-3xl font-semibold text-gray-50 left-0 right-0 top-4">
          <%= @event.user_name %> was first
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(%{event: %Events.ChannelPointsRedemption{reward_title: "second"}} = assigns) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <%!-- <video class="absolute" src={~p"/overlay/videos/#{@video}"} autoplay="true" /> --%>
        <audio src={~p"/overlay/audio/yippee.mp3"} autoplay="true" />
        <span class="absolute text-center text-3xl font-semibold text-gray-50 left-0 right-0 top-4">
          <%= @event.user_name %> was second
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(%{event: %Events.ChannelPointsRedemption{reward_title: "third"}} = assigns) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <%!-- <video class="absolute" src={~p"/overlay/videos/#{@video}"} autoplay="true" /> --%>
        <audio src={~p"/overlay/audio/yippee.mp3"} autoplay="true" />
        <span class="absolute text-center text-3xl font-semibold text-gray-50 left-0 right-0 top-4">
          <%= @event.user_name %> was third
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(%{event: %Events.ChannelPointsRedemption{reward_title: "Hydrate!"}} = assigns) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <%!-- <video class="absolute" src={~p"/overlay/videos/#{@video}"} autoplay="true" /> --%>
        <span class="absolute text-center text-3xl font-semibold text-gray-50 left-0 right-0 top-4">
          <%= @event.user_name %> wants you to drink water
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(%{event: %Events.Cheer{}} = assigns) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <span class="absolute text-center text-3xl font-semibold text-gray-50 left-0 right-0 top-4">
          <%= @event.user_name %> cheered <%= @event.bits %> bits!
          <img src={~p"/overlay/images/makeitrain.gif"} />
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(
        %{event: %Events.ChatNotification{raid: %TwitchEventSub.Fields.Raid{}}} = assigns
      ) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <span class="absolute text-center text-3xl font-semibold text-gray-50 left-0 right-0 top-4">
          Raid from <%= @event.raid.user_name %> with <%= @event.raid.viewer_count %> viewers
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(%{event: %Events.Follow{}} = assigns) do
    ~H"""
    <div class={["absolute mx-auto w-1/3 left-0 right-0", @class]}>
      <div class="relative rounded-lg">
        <video class="absolute" src={~p"/overlay/videos/#{@video}"} autoplay="true" />
        <span class="absolute text-center text-3xl font-semibold text-gray-800 [text-shadow:_1px_1px_0_rgb(255_255_255_/_50%)] left-0 right-0 top-4">
          Hello, <%= @event.user_name %><br /> Thanks for following!
        </span>
      </div>
    </div>
    """
  end

  def twitch_event(%{event: %Events.Sub{}} = assigns) do
    ~H"""
    <div class="hidden">
      <audio src={~p"/overlay/audio/yippee.mp3"} autoplay="true" />
    </div>
    """
  end

  def twitch_event(%{event: %Events.SubGift{total: total}} = assigns) when total >= 10 do
    ~H"""
    <div class={["mx-auto w-1/3 rounded-lg", @class]}>
      <video src={~p"/overlay/videos/earth-is-my-everything.webm"} autoplay="true" />
    </div>
    """
  end

  def twitch_event(%{event: %Events.SubGift{total: total}} = assigns) when total >= 5 do
    ~H"""
    <div class={["mx-auto w-1/3 rounded-lg", @class]}>
      <video src={~p"/overlay/videos/earth-blaster.webm"} autoplay="true" />
    </div>
    """
  end

  def twitch_event(%{event: %Events.SubGift{} = _event} = assigns) do
    ~H"""
    <div class={["mx-auto w-1/3 rounded-lg", @class]}>
      <video src={~p"/overlay/videos/earth-blaster.webm"} autoplay="true" />
    </div>
    """
  end

  def twitch_event(%{event: %Events.Sub{is_gift?: true} = _event} = assigns) do
    ~H"""
    <div class={["mx-auto w-1/3 rounded-lg", @class]}>
      <video src={~p"/overlay/videos/earth-blaster.webm"} autoplay="true" />
    </div>
    """
  end

  # Catch-all, do nothing with events we don't care about.
  def twitch_event(assigns), do: ~H""
end
