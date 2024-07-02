defmodule BattleshipWeb.GameLive.EditComponent do
  @moduledoc """
  This module handles editing(ex. placing ships) of player board
  """
  use BattleshipWeb, :live_component

  alias Battleship.{Gameboard, Ship}

  @impl true
  def mount(socket) do
    {
      :ok,
      assign(socket,
        ship: Ship.get_ship(5),
        second_three_ship_placed: false,
        axis: "x",
        edit: true,
        error: nil,
        access_next_page: false,
        gameboard: Gameboard.generate_board()
      )
    }
  end

  @impl true
  def handle_event("change-axis", _, %{assigns: %{axis: "x"}} = socket),
    do: {:noreply, assign(socket, :axis, "y")}

  def handle_event("change-axis", _, %{assigns: %{axis: "y"}} = socket),
    do: {:noreply, assign(socket, :axis, "x")}

  def handle_event(
        "click",
        %{"row" => row, "col" => col},
        %{assigns: %{gameboard: gameboard, ship: ship, axis: axis}} = socket
      ) do
    case add_ship_to_gameboard(
           gameboard,
           ship,
           [String.to_integer(row), String.to_integer(col)],
           axis
         ) do
      {:ok, new_gameboard} ->
        {:noreply,
         socket
         |> assign(:gameboard, new_gameboard)
         |> assign(:error, nil)
         |> change_ship(ship)}

      {:error, :out_of_range} ->
        {:noreply, assign(socket, error: "Fora de alcance. Selecione outro slot.")}

      {:error, :element_already_present} ->
        {:noreply,
         assign(socket,
           error: "Um navio já está presente nessa faixa de slot. Selecione outro slot."
         )}
    end
  end

  defp change_ship(socket, current_ship) do
    cond do
      current_ship == 5 ->
        assign(socket, :ship, Ship.get_ship(4))

      current_ship == 4 ->
        assign(socket, :ship, Ship.get_ship(3))

      current_ship == 3 and not socket.assigns.second_three_ship_placed ->
        socket
        |> assign(:second_three_ship_placed, true)
        |> assign(:ship, Ship.get_ship(3))

      current_ship == 3 and socket.assigns.second_three_ship_placed ->
        assign(socket, :ship, Ship.get_ship(2))

      current_ship == 2 ->
        send(self(), {:update_player_gameboard, %{gameboard: socket.assigns.gameboard}})
        assign(socket, :edit, false)
        |> assign(:access_next_page, true)
    end
  end

  defp add_ship_to_gameboard(board, ship, [initial_row, inital_col], "x") do
    start_position = [initial_row, inital_col]
    end_position = [initial_row, inital_col + ship - 1]
    Gameboard.put_ship(board, ship, [start_position, end_position])
  end

  defp add_ship_to_gameboard(board, ship, [initial_row, inital_col], "y") do
    start_position = [initial_row, inital_col]
    end_position = [initial_row + ship - 1, inital_col]
    Gameboard.put_ship(board, ship, [start_position, end_position])
  end
end
