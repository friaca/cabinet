defmodule CabinetWeb.ProductControllerTest do
  use CabinetWeb.ConnCase

  import Cabinet.WarehouseFixtures

  @create_attrs %{list_by: :weight, name: "some name", quantity: 42, type: :raw, weight: "120.5"}
  @update_attrs %{list_by: :quantity, name: "some updated name", quantity: 43, type: :final, weight: "456.7"}
  @invalid_attrs %{list_by: nil, name: nil, quantity: nil, type: nil, weight: nil}

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :index))
      assert html_response(conn, 200) =~ "Produtos"
    end
  end

  describe "new product" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :new))
      assert html_response(conn, 200) =~ "Novo Produto"
    end
  end

  describe "create product" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.product_path(conn, :show, id)

      conn = get(conn, Routes.product_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Ver Produto"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert html_response(conn, 200) =~ "Novo Produto"
    end
  end

  describe "edit product" do
    setup [:create_product]

    test "renders form for editing chosen product", %{conn: conn, product: product} do
      conn = get(conn, Routes.product_path(conn, :edit, product))
      assert html_response(conn, 200) =~ "Editar Produto"
    end
  end

  describe "update product" do
    setup [:create_product]

    test "redirects when data is valid", %{conn: conn, product: product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)
      assert redirected_to(conn) == Routes.product_path(conn, :show, product)

      conn = get(conn, Routes.product_path(conn, :show, product))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)
      assert html_response(conn, 200) =~ "Editar Produto"
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert redirected_to(conn) == Routes.product_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.product_path(conn, :show, product))
      end
    end
  end

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end
end
