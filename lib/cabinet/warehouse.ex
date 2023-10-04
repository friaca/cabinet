defmodule Cabinet.Warehouse do
  @moduledoc """
  The Warehouse context.
  """

  import Ecto.Query, warn: false
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
    transactions_query =
      from t in Cabinet.Warehouse.Transaction, where: t.product_id == ^product.id

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:transactions, transactions_query)
    |> Ecto.Multi.delete(:product, product)
    |> Repo.transaction()
    |> case do
      {:ok, %{transactions: _transactions, product: product}} -> {:ok, product}
      {:error, error} -> Repo.rollback(error)
    end
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
  Gets all transactions of a product
  
  ## Examples
  
    iex> get_transactions_by_product_id("0000-000-000-0000")
    [%Transaction{}]
  """
  def get_transactions_by_product_id(product_id) do
    query = from t in Transaction, where: t.product_id == ^product_id, order_by: [desc: t.date]
    Repo.all(query)
  end

  @doc """
  Creates a transaction.
  
  ## Examples
  
      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}
  
      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_transaction(attrs \\ %{}) do
    transaction_changeset =
      %Transaction{}
      |> Transaction.changeset(attrs)

    product_changeset =
      Product.get_changeset_by_transaction(Map.get(attrs, "amount"), Map.get(attrs, "product_id"))

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:transaction, transaction_changeset)
    |> Ecto.Multi.update(:product, product_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction, product: _product}} -> {:ok, transaction}
      {:error, :transaction, changeset, _} -> {:error, changeset}
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
    transaction_changeset =
      transaction
      |> Transaction.changeset(attrs)

    amount_difference =
      Transaction.get_amount_difference(Map.get(transaction, :amount), Map.get(attrs, "amount"))

    product_changeset =
      Product.get_changeset_by_transaction(amount_difference, Map.get(attrs, "product_id"))

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

    product_changeset =
      amount
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

  alias Cabinet.Warehouse.Location

  @doc """
  Returns the list of locations.
  
  ## Examples
  
      iex> list_locations()
      [%Location{}, ...]
  
  """
  def list_locations do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.
  
  Raises `Ecto.NoResultsError` if the Location does not exist.
  
  ## Examples
  
      iex> get_location!(123)
      %Location{}
  
      iex> get_location!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Creates a location.
  
  ## Examples
  
      iex> create_location(%{field: value})
      {:ok, %Location{}}
  
      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.
  
  ## Examples
  
      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}
  
      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.
  
  ## Examples
  
      iex> delete_location(location)
      {:ok, %Location{}}
  
      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.
  
  ## Examples
  
      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}
  
  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  alias Cabinet.Warehouse.LocationProduct

  @doc """
  Returns all products related to locations.
  
  ## Examples
  
      iex> list_location_products()
      [%LocationProduct{}, ...]
  
  """
  def list_location_products() do
    Repo.all(LocationProduct)
  end

  @doc """
  Returns the list of products in a location.
  
  ## Examples
  
      iex> list_location_products_by_location_id(location_id)
      [%LocationProduct{}, ...]
  
  """
  def list_location_products_by_location_id(location_id) do
    Repo.all(
      from lp in LocationProduct,
        join: p in assoc(lp, :product),
        join: l in assoc(lp, :location),
        where: lp.location_id == ^location_id,
        preload: [product: p, location: l]
    )
  end

  @doc """
  Gets a single location product.
  
  Raises `Ecto.NoResultsError` if the LocationProduct does not exist.
  
  ## Examples
  
      iex> get_location_product!(123)
      %LocationProduct{}
  
      iex> get_location_product!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_location_product!(id), do: Repo.get!(LocationProduct, id)

  @doc """
  Checks if product already exists in a location.
  
  ## Examples
  
      iex> product_exists_in_location?("fff-817...", "f43-827...")
      true
  
      iex> product_exists_in_location?("faa-817...", "f41-827...")
      false
  
  """
  def product_exists_in_location?(_location_id, nil), do: false

  def product_exists_in_location?(location_id, product_id),
    do:
      Repo.exists?(
        from lp in LocationProduct,
          where: lp.product_id == ^product_id,
          where: lp.location_id == ^location_id
      )

  # do: Repo.exists?(LocationProduct, where: [product_id: product_id, location_id: location_id])

  @doc """
  Creates a product in a location.
  
  ## Examples
  
      iex> create_location_product(%{field: value})
      {:ok, %LocationProduct{}}
  
      iex> create_location_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_location_product(attrs \\ %{}) do
    %LocationProduct{}
    |> LocationProduct.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product in a location.
  
  ## Examples
  
      iex> update_location_product(location_product, %{field: new_value})
      {:ok, %LocationProduct{}}
  
      iex> update_location_product(location_product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_location_product(%LocationProduct{} = location_product, attrs) do
    location_product
    |> LocationProduct.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product in a location.
  
  ## Examples
  
      iex> delete_location_product(location_product)
      {:ok, %LocationProduct{}}
  
      iex> delete_location_product(location_product)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_location_product(%LocationProduct{} = location_product) do
    Repo.delete(location_product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking a location product changes.
  
  ## Examples
  
      iex> change_location_product(location_product)
      %Ecto.Changeset{data: %LocationProduct{}}
  
  """
  def change_location_product(%LocationProduct{} = location_product, attrs \\ %{}) do
    LocationProduct.changeset(location_product, attrs)
  end
end
