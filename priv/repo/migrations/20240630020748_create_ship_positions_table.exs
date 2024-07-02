defmodule Battleship.Repo.Migrations.CreateShipPositionsTable do
  use Ecto.Migration

  def change do
    create table(:ship_positions) do
      add :ship_id, references(:ships, on_delete: :delete_all)
      add :board_id, references(:boards, on_delete: :delete_all)
      add :starting_position, :string
      add :ending_position, :string
      add :hit_positions, {:array, :string}, default: []

      timestamps()
    end
  end
end
