defmodule Streamer.SongRequest do
  @moduledoc """
  Viewer song request.
  """
  use Streamer.Schema

  import Ecto.Query

  alias Streamer.Repo

  @type t :: %__MODULE__{
          id: UUIDv7.t(),
          track_id: String.t(),
          artists: String.t(),
          name: String.t(),
          user_name: String.t(),
          inserted_at: DateTime.t()
        }

  schema "song_requests" do
    field :track_id, :string
    field :artists, :string
    field :name, :string
    field :user_name, :string
    timestamps(updated_at: false)
  end

  @doc """
  Get the latest song request within the given hours.
  Defaults to `2` hours.
  """
  @spec latest_within(String.t(), pos_integer()) :: t()
  def latest_within(track_id, hours \\ 2) when is_binary(track_id) when hours > 0 do
    hours_ago = DateTime.utc_now() |> DateTime.add(-hours, :hour)

    Repo.one(
      from sr in Streamer.SongRequest,
        where: sr.track_id == ^track_id,
        where: sr.inserted_at > ^hours_ago,
        order_by: [desc: :inserted_at],
        limit: 1
    )
  end
end
