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
  def handle_event("play-again", _params, socket),
    do: {:noreply, assign(socket, action: :edit, game_over: false)}

  @impl true
  def handle_event("singleplayer", _params, socket),
    do: {:noreply, assign(socket, action: :edit)}

  @impl true
  def handle_event("play", _params, socket), do: {:noreply, assign(socket, action: :play)}

  @impl true
  def handle_event("pause-game", %{"game_id" => game_id} = _params, socket) do
    IO.puts("Tentando pausar o jogo com ID: #{game_id}")
    case GameStorage.pause_game(game_id) do
      {:ok, _game} ->
        IO.puts("Jogo pausado com sucesso, redirecionando...")
        {:noreply, push_redirect(socket, to: "/")}
      {:error, reason} ->
        IO.puts("Falha ao pausar o jogo: #{reason}")
        {:noreply, assign(socket, error: "Não foi possível pausar o jogo: #{reason}")}
    end
  end

  @impl true
  def handle_event("resume-game", %{"game_id" => game_id}, socket) do
    IO.puts("Tentando retornar ao jogo com ID: #{game_id}")
    case GameStorage.resume_game(game_id) do
      {:ok, _game} ->
        {:noreply, assign(socket, action: :play)}
      {:error, _reason} ->
        {:noreply, assign(socket, error: "Não foi possível retomar o jogo.")}
    end
  end

  @impl true
  def handle_info({:change_player_name, player_name}, socket) do
    player = Player.update_player_name(socket.assigns.player, player_name)
    {:noreply, assign(socket, player: player)}
  end

  @impl true
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    {:noreply,
     assign(socket, player: Player.update_player_gameboard(socket.assigns.player, gameboard))}
  end

  @impl true
  def handle_info(:set_computer_opponent, socket) do
    opponent =
      Player.new("Computador")
      |> Player.update_player_gameboard(Computer.generate_computer_gameboard())

    {:noreply, assign(socket, opponent: opponent)}
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

  def handle_info(
        %{event: "attack_player", position: %{"row" => row, "col" => col}} = _payload,
        socket
      ) do
    new_player_board =
      Gameboard.attack(socket.assigns.player.gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    player =
      socket.assigns.player
      |> Player.update_player_gameboard(new_player_board)
      |> Player.update_player_chance(true)

    {:noreply, socket |> assign(:player, player)}
  end

  def handle_info(%{event: "availability-check", topic: topic}, socket) do
    Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), topic, %{
      event: "availability",
      from: self(),
      available: !socket.assigns.player.in_game,
      topic: topic
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "availability", available: true, topic: topic}, socket) do
    BattleshipWeb.Endpoint.unsubscribe(topic)

    send_update(self(), BattleshipWeb.GameLive.PrivateRoomComponent,
      id: "private-room-component",
      error: nil
    )

    send(self(), {:private_room, topic})

    {:noreply, socket}
  end

  def handle_info(%{event: "availability", available: false, topic: topic}, socket) do
    send_update(self(), BattleshipWeb.GameLive.PrivateRoomComponent,
      id: "private-room-component",
      error: "Ongoing game",
      room_id: topic
    )

    BattleshipWeb.Endpoint.unsubscribe(topic)

    {:noreply, socket}
  end

  defp unsubscribe_player(socket) do
    room_id = socket.assigns.player.room_id
    BattleshipWeb.Endpoint.unsubscribe(room_id)
    Presence.untrack(self(), room_id, socket.id)
  end
end
