defmodule Battleship.Gameplay.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :status, :string
    field :player_one_id, :integer
    field :player_two_id, :integer

    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:status, :player_one_id, :player_two_id])
    |> validate_required([:status])
  end
end
