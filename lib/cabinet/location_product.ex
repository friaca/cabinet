defmodule Cabinet.Warehouse.LocationProduct do
  alias Cabinet.Warehouse
  alias Cabinet.Warehouse.{Product, Location, LocationProduct}
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
    |> validate_required([:initial_amount, :current_amount, :location_id, :product_id])
    |> validate_unique_product()
  end

  # TODO: Refactor this function, I tried with pattern matching but couldn't do
  def validate_unique_product(changeset) do
    product_id = get_field(changeset, :product_id)
    location_id = get_field(changeset, :location_id)

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

  def get_changeset_by_transaction(transaction_amount, location_id, product_id)
      when transaction_amount != "" and location_id != "" and product_id != "" do
    location_product = Warehouse.get_location_product!(location_id, product_id)
    difference = get_product_difference(transaction_amount, location_product)

    location_product
    |> Ecto.Changeset.cast(%{current_amount: difference}, [:current_amount])
  end

  def get_changeset_by_transaction(_transaction_amount, _location_id, _product_id) do
    %LocationProduct{}
    |> LocationProduct.changeset(%{})
  end

  defp get_product_difference(transaction_amount, location_product) do
    transaction_amount_cast = cast_amount(location_product.product, transaction_amount)

    current_amount =
      cast_amount(location_product.product, Map.get(location_product, :current_amount))

    add_amounts(current_amount, transaction_amount_cast)
  end

  @doc """
  Casts a value to a Decimal or Integer depending on the product type.
  
  Weight: Decimal
  Quantity: Integer
  """
  def cast_amount(product, value) when is_binary(value) do
    {parsed, _} = Decimal.parse(value)
    cast_amount(product, parsed)
  end

  def cast_amount(product, value) do
    if cast_to_integer?(product) do
      Decimal.to_integer(value)
    else
      value
    end
  end

  defp cast_to_integer?(product), do: Map.get(product, :list_by) == :quantity

  def add_amounts(%Decimal{} = amount1, %Decimal{} = amount2) do
    Decimal.add(amount1, amount2)
  end

  def add_amounts(amount1, amount2) do
    amount1 + amount2
  end
end
