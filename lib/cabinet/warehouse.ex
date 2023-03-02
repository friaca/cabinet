defmodule Cabinet.Warehouse do
  @moduledoc """
  The Warehouse context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Repo.Transaction
  alias Cabinet.Repo

  alias Cabinet.Warehouse.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  alias Cabinet.Warehouse.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    transaction_changeset = %Transaction{}
    |> Transaction.changeset(attrs)

    product_changeset = Product.get_changeset_by_transaction(Map.get(attrs, "amount"), Map.get(attrs, "product_id"))

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:transaction, transaction_changeset)
    |> Ecto.Multi.update(:product, product_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction, product: _product}} -> {:ok, transaction}
      {:error, error} -> Repo.rollback(error)
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction_changeset = transaction
    |> Transaction.changeset(attrs)

    amount_difference = Transaction.get_amount_difference(Map.get(transaction, :amount), Map.get(attrs, "amount"))
    product_changeset = Product.get_changeset_by_transaction(amount_difference, Map.get(attrs, "product_id"))

    Ecto.Multi.new()
    |> Ecto.Multi.update(:transaction, transaction_changeset)
    |> Ecto.Multi.update(:product, product_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction, product: _product}} -> {:ok, transaction}
      {:error, error} -> Repo.rollback(error)
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    amount = Map.get(transaction, :amount) |> Decimal.mult(-1)
    product_changeset = amount
    |> Product.get_changeset_by_transaction(Map.get(transaction, :product_id))

    Ecto.Multi.new()
    |> Ecto.Multi.update(:product, product_changeset)
    |> Ecto.Multi.delete(:transaction, transaction)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction, product: _product}} -> {:ok, transaction}
      {:error, error} -> Repo.rollback(error)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
