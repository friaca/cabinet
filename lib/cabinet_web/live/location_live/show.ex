defmodule CabinetWeb.LocationLive.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Warehouse
  alias Cabinet.LocationProduct

  @impl true
  def mount(params, _session, socket) do
    IO.inspect(params)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:location, Warehouse.get_location!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:location, Warehouse.get_location!(id))
  end

  defp apply_action(socket, :add_product, %{"id" => id}) do
    socket
    |> assign(:location, Warehouse.get_location!(id))
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:location_product, %LocationProduct{})
  end

  defp page_title(:show), do: "Localização"
  defp page_title(:edit), do: "Editar localização"
  defp page_title(:add_product), do: "Adicionar produto"
end
