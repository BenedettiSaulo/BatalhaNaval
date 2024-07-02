defmodule Battleship.GameStorage do
  import Ecto.Query, only: [from: 2]
  alias Battleship.Repo
  alias Battleship.Gameplay.Game

  def pause_game(game_id) do
    case Repo.get(Game, game_id) do
      nil ->
        {:error, "Game not found"}
      game ->
        changeset = Game.changeset(game, %{status: "paused"})
        IO.puts("Pausing game: #{inspect changeset}")

        case Repo.update(changeset) do
          {:ok, game} ->
            IO.puts("Game paused successfully")
            {:ok, game}
          {:error, changeset} ->
            IO.puts("Failed to pause game: #{inspect changeset}")
            {:error, changeset}
        end
    end
  end


  def resume_game(game_id) do
    game = Repo.get(Game, game_id)

    changeset =
      game
      |> Game.changeset(%{status: "in_progress"})
      |> Repo.update()

    case changeset do
      {:ok, game} ->
        {:ok, game}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_game(game_id) do
    game = Repo.get(Game, game_id)
    IO.inspect(game, label: "Game retrieved from DB")
    game
  end

  def get_paused_game do
    from(g in Game, where: g.status == "paused", limit: 1)
    |> Repo.one()
  end

  def create_new_game() do
    %Game{status: "active", player_one_id: nil, player_two_id: nil}
    |> Repo.insert()
  end
end
