defmodule CabinetWeb.LocationProductLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.{Product, Location}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      
      <.simple_form
        for={@location_product_form}
        id="location-product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@location_product_form[:location_id]}
          type="select"
          label="Localização"
          options={Location.get_location_options(@id)}
          prompt="Escolha um valor"
          disabled={@id}
          class="bg-slate-200"
        />
        <.input
          field={@location_product_form[:product_id]}
          type="select"
          label="Produto"
          options={Product.get_product_options(@location_product_form)}
          prompt="Escolha um valor"
        />
        <.input
          field={@location_product_form[:initial_amount]}
          type="number"
          label="Quantidade Inicial"
          step="any"
        />
        <%= unless @action == :new_product do %>
          <.input
            field={@location_product_form[:current_amount]}
            type="number"
            label="Quantidade Atual"
            step="any"
            disabled
            class="bg-slate-200"
          />
        <% end %>
        
        <:actions>
          <.button phx-disable-with="Salvando...">Salvar</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{location_product: location_product} = assigns, socket) do
    changeset = Warehouse.change_location_product(location_product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"location_product" => location_product_params}, socket) do
    params =
      if socket.assigns.action == :new_product do
        Map.put(location_product_params, "location_id", socket.assigns.id)
      else
        location_product_params
      end

    changeset =
      socket.assigns.location_product
      |> Warehouse.change_location_product(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"location_product" => location_product_params}, socket) do
    if socket.assigns.id do
      params = Map.put(location_product_params, "location_id", socket.assigns.id)
      save_location_product(socket, socket.assigns.action, params)
    end
  end

  defp save_location_product(socket, :edit_product, location_product_params) do
    case Warehouse.update_location_product(
           socket.assigns.location_product,
           location_product_params
         ) do
      {:ok, location_product} ->
        notify_parent({:saved, location_product})

        {:noreply,
         socket
         |> put_flash(:info, "Localização atualizada com sucesso!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_location_product(socket, :new_product, location_product_params) do
    case Warehouse.create_location_product(location_product_params) do
      {:ok, location_product} ->
        notify_parent({:saved, location_product})

        {:noreply,
         socket
         |> put_flash(:info, "Localização criada com sucesso")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :location_product_form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
