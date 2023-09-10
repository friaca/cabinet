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

  describe "transactions" do
    alias Cabinet.Warehouse.Transaction

    import Cabinet.WarehouseFixtures

    @invalid_attrs %{amount: nil, date: nil, notes: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Warehouse.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Warehouse.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{amount: "120.5", date: ~D[2023-09-09], notes: "some notes"}

      assert {:ok, %Transaction{} = transaction} = Warehouse.create_transaction(valid_attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == ~D[2023-09-09]
      assert transaction.notes == "some notes"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Warehouse.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{amount: "456.7", date: ~D[2023-09-10], notes: "some updated notes"}

      assert {:ok, %Transaction{} = transaction} = Warehouse.update_transaction(transaction, update_attrs)
      assert transaction.amount == Decimal.new("456.7")
      assert transaction.date == ~D[2023-09-10]
      assert transaction.notes == "some updated notes"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Warehouse.update_transaction(transaction, @invalid_attrs)
      assert transaction == Warehouse.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Warehouse.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Warehouse.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Warehouse.change_transaction(transaction)
    end
  end
end
