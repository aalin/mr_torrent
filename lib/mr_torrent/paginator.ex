# https://dev.to/ricardoruwer/create-a-paginator-using-elixir-and-phoenix-1hnk

defmodule MrTorrent.Paginator do
  @moduledoc """
  Paginate your Ecto queries.

  Instead of using: `Repo.all(query)`, you can use: `Paginator.page(query)`.
  To change the page you can pass the page number as the second argument.

  ## Examples

      iex> Paginator.paginate(query, 1)
      [%Item{id: 1}, %Item{id: 2}, %Item{id: 3}, %Item{id: 4}, %Item{id: 5}]

      iex> Paginator.paginate(query, 2)
      [%Item{id: 6}, %Item{id: 7}, %Item{id: 8}, %Item{id: 9}, %Item{id: 10}]

  """

  import Ecto.Query

  alias MrTorrent.Repo

  @default_results_per_page 25

  def paginate(query, page) when is_nil(page) do
    paginate(query, 1)
  end

  def paginate(query, page) when is_binary(page) do
    paginate(query, String.to_integer(page))
  end

  def paginate(query, page, opts \\ []) do
    results_per_page = Keyword.get(opts, :results_per_page, @default_results_per_page)
    results = execute_query(query, page, results_per_page)
    total_results = count_total_results(query)
    total_pages = count_total_pages(total_results, results_per_page)

    %{
      current_page: page,
      results_per_page: results_per_page,
      total_pages: total_pages,
      total_results: total_results,
      list: results
    }
  end

  defp execute_query(query, page, results_per_page) do
    query
    |> limit(^results_per_page)
    |> offset((^page - 1) * ^results_per_page)
    |> Repo.all()
  end

  defp count_total_results(query) do
    Repo.aggregate(query, :count, :id)
  end

  defp count_total_pages(total_results, results_per_page) do
    total_pages = ceil(total_results / results_per_page)

    if total_pages > 0 do
      total_pages
    else
      1
    end
  end
end
