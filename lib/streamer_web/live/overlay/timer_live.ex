defmodule StreamerWeb.Live.Overlay.TimerLive do
  use StreamerWeb, :live_component

  @impl true
  def update(assigns, socket) do
    milliseconds = assigns.total - assigns.tick

    socket =
      socket
      |> assign(:active?, assigns.active)
      |> assign(:title, assigns.title)
      |> assign(:minutes, minutes(milliseconds))
      |> assign(:seconds, seconds(milliseconds))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={[
      "absolute mx-auto top-16 right-16",
      if(!@active?, do: "hidden")
    ]}>
      <div class="relative rounded-lg">
        <p class="text-center text-4xl font-bold text-gray-50 right-0 top-4">
          <%= @title %>
        </p>
        <p class="text-center text-4xl font-bold text-gray-50 right-0 top-4">
          <%= @minutes %>:<%= @seconds %>
        </p>
      </div>
    </div>
    """
  end

  defp minutes(milliseconds) do
    milliseconds
    |> div(60_000)
    |> to_string()
    |> String.pad_leading(2, "0")
  end

  defp seconds(milliseconds) do
    milliseconds
    |> rem(60_000)
    |> div(1000)
    |> to_string()
    |> String.pad_leading(2, "0")
  end
end
