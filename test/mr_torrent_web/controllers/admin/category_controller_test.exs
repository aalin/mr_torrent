defmodule MrTorrentWeb.Admin.CategoryControllerTest do
  use MrTorrentWeb.ConnCase, async: true

  setup :register_and_login_admin

  test "GET /", %{conn: conn} do
    conn = get(conn, "/admin/categories")
    assert html_response(conn, 200) =~ "<h2>Categories</h2>"
  end

  describe "POST /" do
    @valid_params %{"category" => %{"name" => "new category"}}
    @invalid_params %{"category" => %{"name" => ""}}

    test "with valid params", %{conn: conn} do
      conn = post(conn, Routes.admin_category_path(conn, :create), @valid_params)
      assert get_flash(conn, :info) == "Category created successfully"
      assert redirected_to(conn) == Routes.admin_category_path(conn, :index)
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, Routes.admin_category_path(conn, :create), @invalid_params)
      assert html_response(conn, 200) =~ "<li>name can&#39;t be blank</li>"
    end
  end
end
