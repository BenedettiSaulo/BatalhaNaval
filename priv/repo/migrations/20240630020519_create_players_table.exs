defmodule Battleship.Repo.Migrations.CreatePlayersTable do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string

      timestamps()
    end
  end
end
