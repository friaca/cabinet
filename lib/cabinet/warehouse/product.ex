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
    Enum.reduce(enum_mappings()[field], [], fn {enum, translation}, acc ->
      [[key: to_string(translation), value: enum, selected: Map.fetch!(form.data, field) == translation] | acc]
    end)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :type, :weight, :quantity, :list_by])
    |> validate_required([:name, :type, :weight, :quantity, :list_by])
  end
end
