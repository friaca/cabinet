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
    Enum.reduce(Cabinet.Warehouse.list_products(), [], fn product, acc ->
      [[key: product.name, value: product.id, selected: Map.fetch!(form.data, :product_id) == product.id] | acc]
    end)
  end

  @doc false
  def changeset(transaction, attrs) do
    IO.inspect(attrs)
    transaction
    |> cast(attrs, [:date, :amount, :notes, :product_id])
    |> validate_required([:date, :amount, :product_id])
    |> validate_format(:product_id, ~r/^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$/)
  end
end
