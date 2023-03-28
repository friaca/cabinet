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
        quantity: 42,
        type: :raw,
        weight: "120.5"
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
        date: ~D[2023-03-27],
        notes: "some notes"
      })
      |> Cabinet.Warehouse.create_transaction()

    transaction
  end
end
