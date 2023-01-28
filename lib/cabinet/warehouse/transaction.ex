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

  def get_products(form) do
    products = Cabinet.Warehouse.list_products()
    IO.inspect(Enum.at(products, 0))

    Enum.reduce(products, [], fn product, acc ->
      [[key: product.name, value: product.id, selected: Map.fetch!(form.data, :product_id) == product.id] | acc]
    end)

  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :amount, :notes])
    |> validate_required([:date, :amount, :notes])
  end
end
