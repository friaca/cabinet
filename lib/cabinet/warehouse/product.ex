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

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :type, :weight, :quantity, :list_by])
    |> validate_required([:name, :type, :list_by], message: "Can't be blank.")
    |> validate_by_listing()
  end

  defp validate_by_listing(changeset) do
    case get_field(changeset, :list_by) do
      :weight ->
        changeset |> validate_required(:weight, message: "Can't be blank.")

      :quantity ->
        changeset |> validate_required(:quantity, message: "Can't be blank.")

      _ -> changeset
    end
  end
end
