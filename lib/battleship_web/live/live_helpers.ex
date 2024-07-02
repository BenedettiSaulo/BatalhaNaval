defmodule BattleshipWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  def btn(assigns) do
    # Garantir valores padrão para todos os atributos que podem não estar presentes
    assigns =
      assigns
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:class, fn -> "default-button-class" end) # Adicionando uma classe padrão
      |> assign_new(:click, fn -> "" end) # Garantindo que sempre haverá algo para phx-click, mesmo que vazio
      |> assign_new(:to, fn -> "#" end) # Garantindo que sempre haverá um destino para o JS.hide()

    ~H"""
    <%= if @disabled do %>
      <button class={@class} disabled=""><%= render_slot(@inner_block) %></button>
    <% else %>
      <button class={@class} phx-click={JS.hide(to: @to, transition: "fade-out", time: 500) |> JS.push(@click)}><%= render_slot(@inner_block) %></button>
    <% end %>
    """
  end
end
