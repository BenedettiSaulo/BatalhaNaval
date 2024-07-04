defmodule Battleship.GameStorage do
  import Ecto.Query, only: [from: 2]
  alias Battleship.Repo
  alias Battleship.Gameplay.Game

  def pause_game(game_id, player_board, computer_board) do
    # Asegurando que os tabuleiros sejam convertidos para string JSON antes de salvar
    player_board_json = Jason.encode!(player_board)
    computer_board_json = Jason.encode!(computer_board)

    game = Repo.get(Game, game_id)
    changeset = Game.changeset(game, %{status: "paused", player_board: player_board_json, computer_board: computer_board_json})

    case Repo.update(changeset) do
      {:ok, game} -> {:ok, game}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def resume_game(game_id) do
    game = Repo.get(Game, game_id)

    case game do
      nil ->
        {:error, "Jogo não encontrado"}

      game ->
        player_board =
          case Jason.decode!(game.player_board) do
            %{} -> Jason.decode!(game.player_board)
            _ -> %{}
          end

        computer_board =
          case Jason.decode!(game.computer_board) do
            %{} -> Jason.decode!(game.computer_board)
            _ -> %{}
          end

        changeset = Game.changeset(game, %{status: "in_progress"})
        Repo.update(changeset)

        {:ok, {player_board, computer_board}}
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
    %Game{
      status: "active",
      player_board: "[]",    # Representação inicial vazia do tabuleiro do jogador
      computer_board: "[]"   # Representação inicial vazia do tabuleiro do computador
    }
    |> Repo.insert()
  end

end
