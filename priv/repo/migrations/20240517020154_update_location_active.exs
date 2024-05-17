defmodule Cabinet.Repo.Migrations.UpdateLocationActive do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :active, :boolean, default: true
    end
  end
end
