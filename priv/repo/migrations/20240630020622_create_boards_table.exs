defmodule Battleship.Repo.Migrations.CreateBoardsTable do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :game_id, references(:games, on_delete: :delete_all)
      add :player_id, references(:players, on_delete: :delete_all)
      add :status, :string, default: "active"
      add :board_data, :map

      timestamps()
    end

    create index(:boards, [:game_id])
    create index(:boards, [:player_id])
  end
end
