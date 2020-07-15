defmodule MrTorrentWeb.Admin.CategoryController do
  use MrTorrentWeb, :controller

  alias MrTorrent.Torrents

  def index(conn, _params) do
    categories = Torrents.list_categories()
    changeset = Torrents.category_changeset()
    render(conn, "index.html", categories: categories, changeset: changeset)
  end

  def create(conn, params) do
    case Torrents.create_category(params["category"]) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully")
        |> redirect(to: Routes.admin_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Torrents.list_categories()
        render(conn, "index.html", categories: categories, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id} = params) do
    category = Torrents.get_category!(id)
    changeset = Torrents.category_changeset(category)

    render(conn, "edit.html", category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id} = params) do
    category = Torrents.get_category!(id)

    case Torrents.update_category(category, params["category"]) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully")
        |> redirect(to: Routes.admin_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end
end
