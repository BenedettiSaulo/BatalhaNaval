defmodule BattleshipWeb.GameLive.SingleplayerPlayComponent do
  use BattleshipWeb, :live_component

  alias Battleship.{Player, Computer}
  alias Battleship.GameStorage

  @impl true
  def mount(socket) do
    game_id = socket.assigns[:game_id] || create_game().id
    send(self(), :set_computer_opponent)

    {:ok, assign(socket, play_chance: %Player{}, edit_opponent_board: true, game_id: game_id)}
  end

  defp create_game do
    {:ok, game} = GameStorage.create_new_game()
    game
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket =
      if socket.assigns.edit_opponent_board,
        do: assign(socket, play_chance: socket.assigns.player),
        else: socket

    socket =
      if socket.assigns.game_over,
        do: assign(socket, edit_opponent_board: false),
        else: socket

    {:ok, socket}
  end

  @impl true
  def handle_event("click", %{"row" => row, "col" => col}, socket) do
    send(self(), {:attack_opponent, %{position: %{"row" => row, "col" => col}}})

    {:noreply,
     socket
     |> assign(:play_chance, socket.assigns.opponent)
     |> assign(:edit_opponent_board, false)
     |> computer_chance(socket.assigns.player)}
  end

  defp computer_chance(socket, player) do
    :timer.apply_after(
      900,
      BattleshipWeb.GameLive.SingleplayerPlayComponent,
      :send_computer_update,
      [
        self(),
        Computer.get_attack_position(player.gameboard)
      ]
    )

    socket
  end

  def send_computer_update(pid, attack_position) do
    send(pid, {:attack_player, %{position: attack_position}})

    send_update(pid, BattleshipWeb.GameLive.SingleplayerPlayComponent,
      id: "play-component",
      edit_opponent_board: true
    )
  end
end
