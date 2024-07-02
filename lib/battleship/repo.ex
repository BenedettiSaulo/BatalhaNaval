defmodule Battleship.Repo do
  use Ecto.Repo,
    otp_app: :battleship,
    adapter: Ecto.Adapters.Postgres
end
