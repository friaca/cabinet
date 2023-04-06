defmodule CabinetWeb.ProductLive.Index do
  use CabinetWeb, :live_view

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.Product

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :products, Warehouse.list_products())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Produto")
    |> assign(:product, Warehouse.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Produto")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listando Produtos")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({CabinetWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Warehouse.get_product!(id)
    {:ok, _} = Warehouse.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
