defmodule MrTorrentWeb.PaginatorHelper do
  @moduledoc """
  Renders the pagination with a previous button, the pages, and the next button.
  """

  use Phoenix.HTML

  def render(conn, data, class: class) do
    first = prev_button(conn, data)
    pages = page_buttons(conn, data)
    last = next_button(conn, data)

    content_tag(:ul, [first, pages, last], class: class)
  end

  defp prev_button(conn, data) do
    page = data.current_page - 1
    disabled = data.current_page == 1
    params = build_params(conn, page)

    content_tag(:li, disabled: disabled) do
      link to: "?#{params}", rel: "prev" do
        "Prev"
      end
    end
  end

  defp page_buttons(conn, data) do
    for page <- 1..data.total_pages do
      class = if data.current_page == page, do: "active"
      disabled = data.current_page == page
      params = build_params(conn, page)

      content_tag(:li, class: class, disabled: disabled) do
        link(page, to: "?#{params}")
      end
    end
  end

  defp next_button(conn, data) do
    page = data.current_page + 1
    disabled = data.current_page >= data.total_pages
    params = build_params(conn, page)

    content_tag(:li, disabled: disabled) do
      link to: "?#{params}", rel: "next" do
        "Next"
      end
    end
  end

  defp build_params(conn, page) do
    conn.query_params |> Map.put(:page, page) |> URI.encode_query()
  end
end
