defmodule Cabinet.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :weight, :decimal
      add :quantity, :integer
      add :list_by, :string

      timestamps()
    end
  end
end
