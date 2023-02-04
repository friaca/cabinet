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

  defp enum_mappings do
    %{
      :list_by => %{:weight => "Peso", :quantity => "Quantidade"},
      :type => %{:raw => "Material", :final => "Final"}
    }
  end

  def translate_enum(field, value) do
    enum_mappings()[field][value]
  end

  def select_options(field, form) do
    Enum.map(enum_mappings()[field], fn {atom, translation} ->
      [key: to_string(translation), value: atom, selected: Map.fetch!(form.data, field) == translation]
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
