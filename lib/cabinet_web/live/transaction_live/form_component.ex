defmodule CabinetWeb.TransactionLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.{Location, LocationProduct}

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:product_options, fn -> [] end)

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
        />
        <.input field={@form[:date]} type="date" label="Data" />
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
    product_options =
      LocationProduct.get_location_products_options(socket.assigns.form, location_id)

    {:noreply, assign(socket, :product_options, product_options)}
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
