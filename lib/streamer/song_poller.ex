defmodule Streamer.SongPoller do
  use GenServer

  alias Streamer.SpotifyClient

  @interval 5000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_current_track do
    GenServer.call(__MODULE__, :get_current_track)
  end

  def init(_opts) do
    {:ok, %{song: nil}, {:continue, :start}}
  end

  def handle_continue(:start, state) do
    send(self(), :poll)
    {:noreply, state}
  end

  def handle_call(:get_current_track, _from, state) do
    {:reply, state.song, state}
  end

  def handle_info(:poll, state) do
    state =
      case {state.song, current_track()} do
        {song, song} ->
          state

        {_, nil} ->
          Streamer.broadcast("songs:current", {:current_song, nil})
          %{state | song: nil}

        {_, song} ->
          requester = Streamer.SongRequest.latest_within(song.id)

          Streamer.broadcast(
            "songs:current",
            {:current_song, %{song | requester: requester}}
          )

          %{state | song: song}
      end

    Process.send_after(self(), :poll, @interval)

    {:noreply, state}
  end

  defp current_track do
    case SpotifyClient.get_current_track!() do
      %{"is_playing" => true, "item" => track} ->
        %{"album" => %{"images" => images}} = track
        artists = Enum.map_join(track["artists"], ", ", & &1["name"])

        image =
          case List.first(images) do
            %{"url" => url} -> url
            _ -> nil
          end

        %{id: track["id"], artists: artists, track: track["name"], image: image, requester: nil}

      _track ->
        nil
    end
  end
end
