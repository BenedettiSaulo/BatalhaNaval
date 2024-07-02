defmodule Battleship.Repo.Migrations.CreateShipsTable do
  use Ecto.Migration

  def change do
    create table(:ships) do
      add :name, :string
      add :length, :integer

      timestamps()
    end
  end
end
