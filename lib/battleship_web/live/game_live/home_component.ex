defmodule BattleshipWeb.GameLive.HomeComponent do
  use BattleshipWeb, :live_component

  alias Battleship.GameStorage

  @acceptable_name_length 25

  @impl true
  def mount(socket) do
    paused_game = GameStorage.get_paused_game()
    {:ok, assign(socket, paused_game: paused_game, enable_change_name: false, player_name: "Jogador")}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket}
  end

  @impl true
  def handle_event("enable-name-change", _params, socket), do: {:noreply, assign(socket, enable_change_name: true)}

  @impl true
  def handle_event("change-player-name", params, socket) do
    player_name = params["player-name"] |> String.trim()
    len = String.length(player_name)

    socket =
      cond do
        len > 0 && len < @acceptable_name_length ->
          send(self(), {:change_player_name, player_name})
          assign(socket, error: nil, enable_change_name: false, player_name: player_name)

        len < 1 ->
          assign(socket, error: "Por favor insira um nome correto", player_name: "")

        len > @acceptable_name_length ->
          assign(socket, error: "O nome deve ter apenas 25 caracteres", player_name: "")
      end

    {:noreply, socket}
  end

end
