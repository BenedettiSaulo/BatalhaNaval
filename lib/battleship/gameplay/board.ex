defmodule Battleship.Gameplay.Board do
  use Ecto.Schema

  schema "boards" do
    belongs_to :game, Battleship.Gameplay.Game
    belongs_to :player, Battleship.Gameplay.Player

    timestamps()
  end
end
