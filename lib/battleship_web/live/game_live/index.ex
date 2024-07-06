defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.{Gameboard, Player, Computer}
  alias BattleshipWeb.Presence
  alias Battleship.GameStorage

  @type action() :: :index | :edit | :play
  @type game() :: :singleplayer

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       action: :index,
       game: :singleplayer,
       player: Player.new("Jogador"),
       opponent: %Player{},
       game_over: false,
       player_left: false
     )
     }
  end

  @impl true
  def handle_event("index", _params, socket) do
    if socket.assigns.game != :singleplayer && socket.assigns.player.room_id,
      do: unsubscribe_player(socket)

    # Resetar status do player
    {:noreply,
     assign(socket,
       action: :index,
       game: :singleplayer,
       player: Player.reset_state(socket.assigns.player),
       opponent: %Player{},
       game_over: false,
       player_left: false
     )}
  end

  @impl true
  def handle_event("play-again", _params, socket) do

    opponent = Player.new("Computador")

    # {:noreply, assign(socket, action: :edit, game_over: false)}

    {:noreply, socket
      |> assign(:opponent, opponent)
      |> assign(:action, :edit)
      |> assign(:game_over, false)
      |> assign(:game_status, "in_progress")}
  end

  @impl true
  def handle_event("singleplayer", _params, socket),
    do: {:noreply, assign(socket, action: :edit)}

  @impl true
  def handle_event("play", _params, socket), do: {:noreply, assign(socket, action: :play)}

  @impl true
  def handle_event("pause-game", %{"game_id" => game_id, "player_board" => player_board_json, "computer_board" => computer_board_json}, socket) do
    player_board = Jason.decode!(player_board_json) |> convert_keys_to_integers()
    computer_board = Jason.decode!(computer_board_json) |> convert_keys_to_integers()

    case GameStorage.pause_game(game_id, player_board, computer_board) do
      {:ok, _game} ->
        IO.puts("Jogo #{game_id} pausado com sucesso.")
        {:noreply, push_redirect(socket, to: "/")}
      {:error, reason} ->
        IO.puts("Erro ao pausar o jogo #{game_id}: #{inspect(reason)}")
        {:noreply, assign(socket, error: "Não foi possível pausar o jogo: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("resume-game", %{"game_id" => game_id}, socket) do
    IO.puts("Buscando jogo com ID: #{game_id}")

    case GameStorage.resume_game(game_id) do
      {:ok, {player_board, computer_board}} ->

        player_board = convert_keys_to_integers(player_board)
        computer_board = convert_keys_to_integers(computer_board)

        player = Player.new("Jogador") |> Player.update_player_gameboard(player_board)
        opponent = Player.new("Computador") |> Player.update_player_gameboard(computer_board)

        socket =
          socket
          |> assign(:game_id, game_id)
          |> assign(:player, player)
          |> assign(:opponent, opponent)
          |> assign(:action, :play)

        {:noreply, socket}

      {:error, reason} ->
        IO.puts("Falha ao encontrar jogo com ID #{game_id}: #{inspect(reason)}")
        {:noreply, assign(socket, error: "Falha ao encontrar jogo com ID: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_info({:change_player_name, player_name}, socket) do
    player = Player.update_player_name(socket.assigns.player, player_name)
    {:noreply, assign(socket, player: player)}
  end

  @impl true
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    new_player = Player.update_player_gameboard(socket.assigns.player, gameboard)
    {:noreply, assign(socket, player: new_player)}
  end

  @impl true
  def handle_info(:set_computer_opponent, socket) do

    if map_size(socket.assigns.opponent.gameboard) == 0 do
      new_opponent = Player.new("Computador")
                    |> Player.update_player_gameboard(Computer.generate_computer_gameboard())
      {:noreply, assign(socket, opponent: new_opponent)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:attack_player, %{position: position}}, socket) do
    %{"row" => row, "col" => col} = position

    new_player_gameboard = Gameboard.attack(socket.assigns.player.gameboard, [row, col])
    player = Player.update_player_gameboard(socket.assigns.player, new_player_gameboard)

    socket = assign(socket, player: player)

    if Gameboard.has_won?(new_player_gameboard) do
      opponent = Player.set_win(socket.assigns.opponent, true)
      {:noreply, socket |> assign(:game_over, true) |> assign(:opponent, opponent)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        {:attack_opponent, %{position: position}},
        %{assigns: %{game: :singleplayer}} = socket
      ) do
    %{"row" => row, "col" => col} = position

    new_opponent_board =
      Gameboard.attack(socket.assigns.opponent.gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    opponent = Player.update_player_gameboard(socket.assigns.opponent, new_opponent_board)

    socket = assign(socket, :opponent, opponent)

    if Gameboard.has_won?(new_opponent_board) do
      player = Player.set_win(socket.assigns.player, true)
      {:noreply, socket |> assign(:game_over, true) |> assign(:player, player)}
    else
      {:noreply, socket}
    end
  end


  defp unsubscribe_player(socket) do
    room_id = socket.assigns.player.room_id
    BattleshipWeb.Endpoint.unsubscribe(room_id)
    Presence.untrack(self(), room_id, socket.id)
  end

  defp convert_keys_to_integers(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_integer(k), convert_keys_to_integers(v)} end)
    |> Enum.into(%{})
  end

  defp convert_keys_to_integers(value), do: value
end
