defmodule CabinetWeb.ProductLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.Product

  @impl true
  def render(assigns) do
    assigns =
      assign_new(assigns, :selected_listing, fn -> assigns.form.data.list_by end)

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
          options={Product.select_options(:type, @form)}
        />
        <.input
          field={@form[:list_by]}
          type="select"
          label="Listagem"
          prompt="Escolha um valor"
          options={Product.select_options(:list_by, @form)}
          disabled={disabled?(@action)}
          class={disabled?(@action) && "bg-slate-200"}
        />
        <:actions>
          <.button phx-disable-with="Salvando...">Salvar produto</.button>
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

  defp save_product(socket, :edit, product_params) do
    case Warehouse.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Produto atualizado com sucesso!")
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
         |> put_flash(:info, "Produto criado com sucesso!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Prevent user from changing from Quantity to Weight and vice-versa after
  # the product is already created
  defp disabled?(action), do: action == :edit
end
