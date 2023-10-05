defmodule Cabinet.Repo.Migrations.RemoveAmountProduct do
  use Ecto.Migration

  def change do
    alter table(:products) do
      remove :quantity
      remove :weight
    end
  end
end
