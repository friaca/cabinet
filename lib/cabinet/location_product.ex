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
  end
end
