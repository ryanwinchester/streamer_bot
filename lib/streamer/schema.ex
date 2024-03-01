defmodule Streamer.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      @primary_key {:id, UUIDv7, autogenerate: true}
      @foreign_keys UUIDv7
    end
  end
end
