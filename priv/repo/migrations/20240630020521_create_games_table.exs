defmodule Battleship.Repo.Migrations.CreateGamesTable do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :status, :string
      add :player_board, :text
      add :computer_board, :text

      timestamps()
    end
  end
end
