defmodule Battleship.Gameplay.Ship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ships" do
    field :type, :integer
    belongs_to :board, Battleship.Gameplay.Board
    timestamps()
  end

  def changeset(ship, attrs) do
    ship
    |> cast(attrs, [:type, :board_id])
    |> validate_required([:type, :board_id])
  end
end
