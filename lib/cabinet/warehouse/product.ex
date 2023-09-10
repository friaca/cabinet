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

  def translate_enum(field, value) do
    enum_mappings()[field][value]
  end

  def select_options(field, form) do
    Enum.reduce(enum_mappings()[field], [], fn {enum, translation}, acc ->
      [
        [
          key: to_string(translation),
          value: enum,
          selected: Map.fetch!(form.data, field) == translation
        ]
        | acc
      ]
    end)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :type, :weight, :quantity, :list_by])
    |> validate_required([:name, :type, :list_by], message: "Não pode ficar em branco.")
    |> validate_listing()
  end

  def cast_listing(product, value) when is_binary(value) do
    {decimal, _} = Decimal.parse(value)
    cast_listing(product, decimal)
  end

  def cast_listing(product, value) do
    if cast_to_integer?(product) do
      Decimal.to_integer(value)
    else
      value
    end
  end

  def get_changeset_by_transaction(transaction_amount, product_id) do
    product = Cabinet.Warehouse.get_product!(product_id)
    {field, difference} = get_product_difference(transaction_amount, product)

    product
    |> Ecto.Changeset.cast(%{field => difference}, [field])
  end

  defp cast_to_integer?(product), do: Map.get(product, :list_by) == :quantity

  defp validate_listing(changeset) do
    case get_field(changeset, :list_by) do
      nil -> changeset
      field -> changeset |> validate_required(field, message: "Não pode ficar em branco.")
    end
  end

  defp get_product_difference(transaction_amount, product) do
    list_by = Map.get(product, :list_by)
    transaction_amount_cast = product |> cast_listing(transaction_amount)

    {list_by, Map.get(product, list_by) + transaction_amount_cast}
  end

  defp enum_mappings do
    %{
      :list_by => %{:weight => "Peso", :quantity => "Quantidade"},
      :type => %{:raw => "Material", :final => "Final"}
    }
  end
end
