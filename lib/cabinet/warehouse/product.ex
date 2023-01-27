defmodule Cabinet.Warehouse.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :list_by, Ecto.Enum, values: [Peso: "weight", Quantidade: "quantity"]
    field :name, :string
    field :quantity, :integer
    field :type, Ecto.Enum, values: [Material: "raw", Final: "final"]
    field :weight, :decimal

    timestamps()
  end

  def select_options(field, form) do
    Enum.reduce(Ecto.Enum.mappings(Cabinet.Warehouse.Product, field), [], fn {key, value}, acc ->
      [[key: to_string(key), value: value, selected: Map.fetch!(form.data, field) == key] | acc]
    end)
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
end
