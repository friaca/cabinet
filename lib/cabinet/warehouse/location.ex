defmodule Cabinet.Warehouse.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "locations" do
    field :name, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :active])
    |> validate_required([:name, :active])
  end

  def get_location_options(form) when is_map(form) do
    locations = Cabinet.Warehouse.list_locations()

    Enum.reduce(locations, [], fn location, acc ->
      [
        [
          key: location.name,
          value: location.id,
          selected: Map.fetch!(form.data, :id) == location.id
        ]
        | acc
      ]
    end)
  end

  def get_location_options(location_id) when is_binary(location_id) do
    locations = Cabinet.Warehouse.list_locations()

    Enum.reduce(locations, [], fn location, acc ->
      [
        [
          key: location.name,
          value: location.id,
          selected: location_id == location.id
        ]
        | acc
      ]
    end)
  end
end
