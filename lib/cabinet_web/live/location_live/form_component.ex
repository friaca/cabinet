defmodule CabinetWeb.LocationLive.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Warehouse

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      
      <.simple_form
        for={@form}
        id="location-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nome" />
        <.input
          field={@form[:active]}
          type="select"
          label="Ativo"
          options={location_active_select_options(@form)}
        />
        <:actions>
          <.button phx-disable-with="Salvando...">Salvar localização</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{location: location} = assigns, socket) do
    changeset = Warehouse.change_location(location)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset =
      socket.assigns.location
      |> Warehouse.change_location(location_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    location_params = parse_active(location_params)
    save_location(socket, socket.assigns.action, location_params)
  end

  defp parse_active(params) do
    IO.inspect(params)

    Map.update(params, "active", true, fn value -> Helpers.convert!(value) end) |> IO.inspect()
  end

  defp save_location(socket, :edit, location_params) do
    case Warehouse.update_location(socket.assigns.location, location_params) do
      {:ok, location} ->
        notify_parent({:saved, location})

        {:noreply,
         socket
         |> put_flash(:info, "Localização atualizada com sucesso!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_location(socket, :new, location_params) do
    case Warehouse.create_location(location_params) do
      {:ok, location} ->
        notify_parent({:saved, location})

        {:noreply,
         socket
         |> put_flash(:info, "Localização criada com sucesso")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp location_active_select_options(form) do
    [
      [key: "Sim", value: 1, selected: Map.fetch!(form.data, :active) == true],
      [key: "Não", value: 0, selected: Map.fetch!(form.data, :active) == false]
    ]
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
