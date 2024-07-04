defmodule Battleship.Gameplay.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :status, :string
    field :player_board, :string
    field :computer_board, :string

    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:status, :player_board, :computer_board])
    |> validate_required([:status, :player_board, :computer_board])
  end
end
