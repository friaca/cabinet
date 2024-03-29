defmodule Cabinet.WarehouseFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cabinet.Warehouse` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        list_by: :weight,
        name: "some name",
        type: :raw
      })
      |> Cabinet.Warehouse.create_product()

    product
  end

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        date: ~D[2023-09-09],
        notes: "some notes"
      })
      |> Cabinet.Warehouse.create_transaction()

    transaction
  end

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Cabinet.Warehouse.create_location()

    location
  end
end
