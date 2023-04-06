defmodule CabinetWeb.ProductLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse

  @impl true
  def render(assigns) do
    list_by_value = Map.get(assigns, :form)
    |> Map.get(:data)
    |> Map.get(:list_by)

    assigns = assign(assigns, :list_by_value, list_by_value)
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nome" />
        <.input
          field={@form[:type]}
          type="select"
          label="Tipo"
          prompt="Escolha um valor"
          options={(Cabinet.Warehouse.Product.select_options(:type, @form.data))}
        />
        <.input
          field={@form[:list_by]}
          type="select"
          label="Listar por"
          prompt="Escolha um valor"
          options={(Cabinet.Warehouse.Product.select_options(:list_by, @form.data))}
          phx-change="listing-change"
        />
        <.input container_class={@list_by_value == :quantity && "hidden"} field={@form[:weight]} type="number" label="Peso (Kg/L)" step="any" />
        <.input container_class={@list_by_value == :weight && "hidden"} field={@form[:quantity]} type="number" label="Quantidade" />
        <:actions>
          <.button phx-disable-with="Salvando...">Salvar Produto</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Warehouse.change_product(product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Warehouse.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  def handle_event("listing-change", %{"product" => %{"list_by" => listing}}, socket) do
    {:noreply, push_event(socket, "listing-change", %{ newListing: listing })}
  end

  defp save_product(socket, :edit, product_params) do
    case Warehouse.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Warehouse.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
