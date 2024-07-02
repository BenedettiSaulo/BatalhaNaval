defmodule Battleship.Repo.Migrations.CreateGamesTable do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :status, :string
      add :player_one_id, references(:players, on_delete: :nothing)
      add :player_two_id, references(:players, on_delete: :nothing)

      timestamps()
    end
  end
end
