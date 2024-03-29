defmodule CabinetWeb.LocationLive.Index do
  use CabinetWeb, :live_view

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.Location

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :locations, Warehouse.list_locations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar localização")
    |> assign(:location, Warehouse.get_location!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova localização")
    |> assign(:location, %Location{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Localizações")
    |> assign(:location, nil)
  end

  @impl true
  def handle_info({CabinetWeb.LocationLive.FormComponent, {:saved, location}}, socket) do
    {:noreply, stream_insert(socket, :locations, location)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Warehouse.get_location!(id)
    {:ok, _} = Warehouse.delete_location(location)

    {:noreply, stream_delete(socket, :locations, location)}
  end
end
