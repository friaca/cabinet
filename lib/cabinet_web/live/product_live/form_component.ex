defmodule CabinetWeb.ProductLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Warehouse.change_product(product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Warehouse.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  def handle_event("list_by_change", %{"product" => listing}, socket) do
    {:noreply, push_event(socket, "show-product-listing", %{"field" => Map.get(listing, "list_by")})}
  end

  def hidden_if_not_equals(original, term) do
    if original == term do
      [class: ""]
    else
      [class: "hidden"]
    end
  end

  defp save_product(socket, :edit, product_params) do
    case Warehouse.update_product(socket.assigns.product, product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Produto atualizado com sucesso!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Warehouse.create_product(product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Produto criado com sucesso!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
