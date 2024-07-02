defmodule Battleship.Gameplay.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :name, :string
    has_many :games_as_player_one, Battleship.Gameplay.Game, foreign_key: :player_one_id
    has_many :games_as_player_two, Battleship.Gameplay.Game, foreign_key: :player_two_id
    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
