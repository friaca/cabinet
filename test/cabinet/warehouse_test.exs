defmodule Cabinet.WarehouseTest do
  use Cabinet.DataCase

  alias Cabinet.Warehouse

  describe "products" do
    alias Cabinet.Warehouse.Product

    import Cabinet.WarehouseFixtures

    @invalid_attrs %{list_by: nil, name: nil, quantity: nil, type: nil, weight: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Warehouse.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Warehouse.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{list_by: :weight, name: "some name", quantity: 42, type: :raw, weight: "120.5"}

      assert {:ok, %Product{} = product} = Warehouse.create_product(valid_attrs)
      assert product.list_by == :weight
      assert product.name == "some name"
      assert product.quantity == 42
      assert product.type == :raw
      assert product.weight == Decimal.new("120.5")
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Warehouse.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{list_by: :quantity, name: "some updated name", quantity: 43, type: :final, weight: "456.7"}

      assert {:ok, %Product{} = product} = Warehouse.update_product(product, update_attrs)
      assert product.list_by == :quantity
      assert product.name == "some updated name"
      assert product.quantity == 43
      assert product.type == :final
      assert product.weight == Decimal.new("456.7")
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Warehouse.update_product(product, @invalid_attrs)
      assert product == Warehouse.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Warehouse.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Warehouse.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Warehouse.change_product(product)
    end
  end
end
