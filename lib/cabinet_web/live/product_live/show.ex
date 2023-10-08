defmodule CabinetWeb.ProductLive.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.Product

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    product = Warehouse.get_product!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, product))
     |> assign(:product, product)}
  end

  def list_locations_with_product(product_id) do
    Warehouse.list_locations_with_product(product_id)
  end

  defp page_title(_action, product), do: product.name
end
