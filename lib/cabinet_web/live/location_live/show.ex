defmodule CabinetWeb.LocationLive.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.LocationProduct

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     stream(
       socket,
       :location_products,
       Warehouse.list_location_products_by_location_id(Map.get(params, "id"))
     )}
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

  defp apply_action(socket, :new_product, %{"id" => id}) do
    socket
    |> assign(:location, Warehouse.get_location!(id))
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:location_product, %LocationProduct{})
  end

  defp apply_action(socket, :edit_product, %{"id" => id, "product_id" => product_id}) do
    socket
    |> assign(:location, Warehouse.get_location!(id))
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:location_product, Warehouse.get_location_product!(id, product_id))
  end

  @impl true
  def handle_info(
        {CabinetWeb.LocationProductLive.FormComponent, {:saved, location_product}},
        socket
      ) do
    {:noreply, stream_insert(socket, :location_products, location_product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Warehouse.get_location_product!(id)
    {:ok, _} = Warehouse.delete_location_product(product)
    IO.inspect(socket)

    {:noreply, stream_delete(socket, :location_products, product)}
  end

  defp page_title(:show), do: "Localização"
  defp page_title(:edit), do: "Editar localização"
  defp page_title(:new_product), do: "Adicionar produto"
  defp page_title(:edit_product), do: "Editar produto"
end
