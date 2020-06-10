defmodule MrTorrentWeb.PaginatorHelper do
  @moduledoc """
  Renders the pagination with a previous button, the pages, and the next button.
  """

  use Phoenix.HTML
  import MrTorrentWeb.NumberHelper, only: [format_number: 1]

  @default_window_size 10

  def render(conn, data, opts \\ []) do
    window_size = Keyword.get(opts, :window_size, @default_window_size)
    class = Keyword.get(opts, :class)

    prev = prev_button(conn, data)
    pages = page_buttons(conn, data, window_size)
    next = next_button(conn, data)

    content_tag(:div, class: class) do
      [
        description(data),
        content_tag(:ul, [prev, pages, next])
      ]
    end
  end

  defp description(data) do
    first = (data.current_page - 1) * data.results_per_page + 1
    last = min(data.current_page * data.results_per_page, data.total_results)

    content_tag(:p, [
      content_tag(:strong, "#{format_number(first)} – #{format_number(last)}"),
      " of total ",
      content_tag(:strong, "#{format_number(data.total_results)} torrents")
    ])
  end

  defp page_buttons(conn, data, window_size) do
    {first_index, last_index} =
      pagination_window(
        data.current_page,
        data.total_pages,
        min(data.total_pages, window_size)
      )

    for page <- first_index..last_index do
      class = if data.current_page == page, do: "active"
      disabled = data.current_page == page
      params = build_params(conn, page)

      content_tag(:li, class: class, disabled: disabled) do
        link(page, to: "?#{params}")
      end
    end
  end

  defp prev_button(conn, data) do
    relative_navigation_button(conn, data, data.current_page - 1, "Prev", rel: "prev")
  end

  defp next_button(conn, data) do
    relative_navigation_button(conn, data, data.current_page + 1, "Next", rel: "next")
  end

  defp relative_navigation_button(conn, data, page, text, rel: rel) do
    disabled = page < 1 or page > data.total_pages
    params = build_params(conn, page)

    content_tag(:li) do
      if disabled do
        content_tag(:span, text)
      else
        link(to: "?#{params}", rel: rel, do: text)
      end
    end
  end

  defp build_params(conn, page) do
    conn.query_params |> Map.put("page", page) |> URI.encode_query()
  end

  defp pagination_window(current_page, total_pages, window_size) do
    half_window_size = (window_size - 1) / 2
    first = current_page - ceil(half_window_size) - 1
    last = current_page + floor(half_window_size)

    cond do
      first < 1 ->
        {1, min(last - first, window_size)}

      last >= total_pages ->
        {max(total_pages + first - last, 1), total_pages}

      true ->
        {first, last}
    end
  end
end
