defmodule Streamer.Repo.Migrations.CreateSongRequests do
  use Ecto.Migration

  def change do
    create table(:song_requests, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :track_id, :string, null: false
      add :artists, :string, null: false
      add :name, :string, null: false
      add :user_name, :string, null: false
      timestamps(updated_at: false)
    end

    create index(:song_requests, [:track_id])
  end
end
