defmodule Cabinet.Warehouse.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :decimal
    field :date, :date
    field :notes, :string
    field :product_id, :binary_id

    timestamps()
  end

  defp is_valid_integer(amount) do
    case Integer.parse(Decimal.to_string(amount)) do
      {_value, remainder} -> remainder == ""
      :error -> false
    end
  end

  def get_products(form) do
    products = Cabinet.Warehouse.list_products()

    Enum.reduce(products, [], fn product, acc ->
      [
        [
          key: product.name,
          value: product.id,
          selected: Map.fetch!(form.data, :product_id) == product.id
        ]
        | acc
      ]
    end)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :amount, :notes, :product_id])
    |> validate_required([:date, :amount, :product_id], message: "Não pode ficar em branco.")
    |> validate_amount(attrs)
  end

  defp validate_amount(%{valid?: false} = changeset, _attrs), do: changeset

  defp validate_amount(changeset, attrs) when map_size(attrs) == 0 do
    changeset
  end

  defp validate_amount(changeset, attrs) when map_size(attrs) > 0 do
    product = Cabinet.Warehouse.get_product!(Map.fetch!(attrs, "product_id"))

    validate_change(changeset, :amount, fn field, value ->
      case Map.fetch!(product, :list_by) do
        :quantity ->
          if is_valid_integer(value) do
            []
          else
            [{field, "Couldn't cast `amount` to an integer"}]
          end

        :weight ->
          []
      end
    end)
  end

  def get_amount_difference(%Decimal{} = amount1, amount2) do
    {amount2, _} = Decimal.parse(amount2)

    case Decimal.compare(amount1, amount2) do
      :gt ->
        Decimal.sub(amount2, amount1)
        |> Decimal.abs()
        |> Decimal.mult(-1)

      :lt ->
        Decimal.sub(amount2, amount1)
        |> Decimal.abs()

      :eq ->
        amount1
    end
  end

  def get_amount_difference(amount1, amount2) do
    cond do
      amount2 > amount1 -> abs(amount2 - amount1)
      amount2 < amount1 -> abs(amount2 - amount1) * -1
      amount2 == amount1 -> amount1
    end
  end
end
