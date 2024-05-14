defmodule CabinetWeb.TransactionLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.{Location, LocationProduct}

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:product_options, fn -> assign_product_options(assigns) end)
      |> assign_new(:valid_location, fn -> assign_valid_location(assigns) end)

    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      
      <.simple_form
        for={@form}
        id="transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:location_id]}
          type="select"
          label="Localização"
          options={Location.get_location_options(@form)}
          prompt="Escolha um valor"
          phx-change="set_product_list"
        />
        <.input
          field={@form[:product_id]}
          type="select"
          label="Produto"
          options={@product_options}
          prompt="Escolha um valor"
          disabled={!@valid_location}
          class={if !@valid_location, do: "bg-slate-200"}
        /> <.input field={@form[:date]} type="date" label="Data" />
        <.input field={@form[:amount]} type="number" label="Quantidade" step="any" />
        <.input field={@form[:notes]} type="text" label="Notas" />
        <:actions>
          <.button phx-disable-with="Salvando...">Salvar transação</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Warehouse.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Warehouse.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  def handle_event(
        "set_product_list",
        %{"transaction" => %{"location_id" => location_id}},
        socket
      ) do
    product_options = get_product_options(socket.assigns.form, location_id)

    socket =
      socket
      |> assign(:product_options, product_options)
      |> put_location_id_changeset(location_id)

    {:noreply, socket}
  end

  defp put_location_id_changeset(socket, location_id) do
    changeset =
      socket.assigns.transaction
      |> Warehouse.change_transaction(%{"location_id" => location_id})
      |> Map.put(:action, :validate)

    assign_form(socket, changeset)
  end

  defp assign_valid_location(assigns) do
    if assigns.action == :new do
      !Helpers.nil_or_empty?(Map.get(assigns.form.params, "location_id"))
    else
      true
    end
  end

  defp assign_product_options(assigns) do
    if assigns.action == :edit do
      get_product_options(assigns.form, assigns.form.data.location_id)
    else
      []
    end
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Warehouse.update_transaction(socket.assigns.transaction, transaction_params) do
      {:ok, transaction} ->
        notify_parent({:saved, transaction})

        {:noreply,
         socket
         |> put_flash(:info, "Transação atualizada com sucesso!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    case Warehouse.create_transaction(transaction_params) do
      {:ok, transaction} ->
        notify_parent({:saved, transaction})

        {:noreply,
         socket
         |> put_flash(:info, "Transação criada com sucesso!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp get_product_options(_form, ""), do: []

  defp get_product_options(form, location_id) do
    LocationProduct.get_location_products_options(form, location_id)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
