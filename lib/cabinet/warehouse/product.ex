defmodule Cabinet.Warehouse.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :list_by, Ecto.Enum, values: [:weight, :quantity]
    field :name, :string
    field :quantity, :integer
    field :type, Ecto.Enum, values: [:raw, :final]
    field :weight, :decimal

    timestamps()
  end

  defp enum_mappings(key) do
    %{
      :list_by => %{:weight => "Peso (Kg/L)", :quantity => "Quantidade"},
      :type => %{:raw => "Material", :final => "Final"}
    }[key]
  end

  defp label_mappings(key) do
    %{
      :weight => "Peso (Kg/L)",
      :quantity => "Quantidade"
    }[key]
  end

  def translate_enum(field, value) do
    enum_mappings(field)[value]
  end

  def select_options(field, product) do
    Enum.map(enum_mappings(field), fn {atom, translation} ->
      [key: to_string(translation), value: atom, selected: Map.fetch!(product, field) == translation]
    end)
  end

  def is_existing_product?(product), do: product.id != nil

  def get_listing_value(product) do
    list_by = Map.get(product, :list_by)
    Map.get(product, list_by)
  end

  def get_listing_label(product) do
    Map.get(product, :list_by)
    |> label_mappings()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :type, :weight, :quantity, :list_by])
    |> validate_required([:name, :type, :list_by], message: "Não pode ficar em branco.")
    |> validate_by_listing()
  end

  defp validate_by_listing(changeset) do
    case get_field(changeset, :list_by) do
      :weight ->
        changeset |> validate_required(:weight, message: "Não pode ficar em branco.")

      :quantity ->
        changeset |> validate_required(:quantity, message: "Não pode ficar em branco.")

      _ -> changeset
    end
  end

  defp cast_to_integer?(product), do: Map.get(product, :list_by) == :quantity

  def cast_listing(product, value) when is_binary(value) do
    { decimal, _ } = Decimal.parse(value)
    cast_listing(product, decimal)
  end

  def cast_listing(product, value) do
    if cast_to_integer?(product) do
      Decimal.to_integer(value)
    else
      value
    end
  end

  defp get_product_difference(transaction_amount, product) do
    list_by = Map.get(product, :list_by)
    transaction_amount_cast = product |> cast_listing(transaction_amount)

    { list_by, Map.get(product, list_by) + transaction_amount_cast }
  end

  def get_changeset_by_transaction(transaction_amount, product_id) do
    product = Cabinet.Warehouse.get_product!(product_id)
    { field, difference } = get_product_difference(transaction_amount, product)

    product
    |> Ecto.Changeset.cast(%{field => difference}, [field])
  end
end
