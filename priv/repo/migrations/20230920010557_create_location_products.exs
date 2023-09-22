defmodule Cabinet.Repo.Migrations.CreateLocationProducts do
  use Ecto.Migration

  def change do
    create table(:location_products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :initial_amount, :decimal
      add :current_amount, :decimal
      add :location_id, references(:locations, on_delete: :nothing, type: :binary_id)
      add :product_id, references(:products, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:location_products, [:location_id])
    create index(:location_products, [:product_id])
  end
end
