defmodule Cabinet.Warehouse.LocationProduct do
  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.{Product, Location}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "location_products" do
    field :current_amount, :decimal
    field :initial_amount, :decimal
    belongs_to :product, Product
    belongs_to :location, Location

    timestamps()
  end

  @doc false
  def changeset(location_product, attrs) do
    location_product
    |> cast(attrs, [:initial_amount, :current_amount, :location_id, :product_id])
    |> validate_required([:initial_amount, :location_id, :product_id])
    |> validate_unique_product()
  end

  # TODO: Refactor this function, I tried with
  def validate_unique_product(changeset) do
    product_id = get_field(changeset, :product_id)
    location_id = get_field(changeset, :location_id)
    IO.inspect(changeset)

    case product_id do
      nil ->
        changeset

      id ->
        case Warehouse.product_exists_in_location?(location_id, id) do
          true -> add_error(changeset, :product_id, "Produto já existe na localização")
          false -> changeset
        end
    end
  end

  def get_location_products_options(form, location_id) do
    location_products =
      Warehouse.list_location_products_by_location_id(location_id)

    Enum.reduce(location_products, [], fn lp, acc ->
      [
        [
          key: lp.product.name,
          value: lp.product.id,
          selected: Map.fetch!(form.data, :product_id) == lp.product.id
        ]
        | acc
      ]
    end)
  end
end
