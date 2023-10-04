defmodule Cabinet.Repo.Migrations.AddLocationToTransaction do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :location_id, references(:locations, on_delete: :nothing, type: :binary_id)
    end
  end
end
