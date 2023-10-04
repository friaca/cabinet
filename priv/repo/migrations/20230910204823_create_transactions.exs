defmodule Cabinet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :amount, :decimal
      add :notes, :text
      add :product_id, references(:products, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:transactions, [:product_id])
  end
end
