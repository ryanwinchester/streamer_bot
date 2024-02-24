defmodule Streamer.SpotifyClient do
  @moduledoc """
  Spotify API Client.
  https://developer.spotify.com/documentation/web-api
  """

  @base_url "https://api.spotify.com/v1"

  @doc """
  Get an access token using the refresh token.
  """
  def get_access_token!(client_id, client_secret, refresh_token) do
    Req.post!(
      url: "https://accounts.spotify.com/api/token",
      auth: {:basic, "#{client_id}:#{client_secret}"},
      form: %{
        grant_type: "refresh_token",
        refresh_token: refresh_token
      }
    ).body
  end

  @doc """
  Get the info for a track by the spotify link or track ID.
  """
  def get_track!("https://open.spotify.com/track/" <> rest) do
    rest
    |> String.split("?")
    |> List.first()
    |> get_track!()
  end

  def get_track!(id) when is_binary(id) do
    Req.get!(client(), url: "/tracks/#{id}").body
  end

  @doc """
  Get the current song.
  See: https://developer.spotify.com/documentation/web-api/reference/get-the-users-currently-playing-track
  """
  @spec get_current_track!() :: map()
  def get_current_track! do
    Req.get!(client(), url: "/me/player/currently-playing").body
  end

  @doc """
  Get the current song and queue.
  """
  @spec get_queue!() :: {current_track_id :: String.t(), queue :: [String.t()]}
  def get_queue! do
    %{
      "currently_playing" => %{"id" => track_id},
      "queue" => queue
    } = Req.get!(client(), url: "/me/player/queue").body

    {track_id, Enum.map(queue, & &1["id"])}
  end

  @doc """
  Add a track to the next position in the now-playing queue.
  """
  def add_track_to_queue!(track_id) do
    Req.post!(client(),
      url: "/me/player/queue",
      headers: %{"content-length" => 0},
      params: [uri: "spotify:track:#{track_id}"]
    ).body
  end

  # ----------------------------------------------------------------------------
  # Helpers
  # ----------------------------------------------------------------------------

  defp client do
    Req.new(base_url: @base_url)
    |> Req.Request.append_request_steps(add_token: &add_token/1)
  end

  defp add_token(request) do
    %{
      client_id: client_id,
      client_secret: client_secret,
      refresh_token: refresh_token
    } = Application.fetch_env!(:streamer, __MODULE__) |> Map.new()

    token = get_access_token!(client_id, client_secret, refresh_token)["access_token"]

    Req.Request.put_header(request, "authorization", "Bearer #{token}")
  end
end
