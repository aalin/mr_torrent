defmodule MrTorrent.Torrents.Filter do
  import Ecto.Query

  def filter_torrents_query(opts \\ []) do
    from torrent in MrTorrent.Torrents.Torrent,
      left_join: gc in subquery(grab_count_subquery()), on: gc.torrent_id == torrent.id,
      select_merge: %{
        grab_count: coalesce(gc.grab_count, 0)
      },
      where: ^filter_where(opts),
      preload: [:files, :category]
  end

  defp grab_count_subquery do
    from access in MrTorrent.Torrents.Access,
      select: %{grab_count: count(access.id), torrent_id: access.torrent_id},
      group_by: access.torrent_id
  end

  defp filter_where(opts) do
    Enum.reduce(opts, dynamic(true), fn
      {:category_ids, []}, dynamic ->
        dynamic

      {:category_ids, category_ids}, dynamic when is_list(category_ids) ->
        dynamic([torrent], ^dynamic and torrent.category_id in ^category_ids)

      {:query, ""}, dynamic ->
        dynamic

      {:query, query}, dynamic when is_binary(query) ->
        terms = query_to_terms(query)

        dynamic([torrent], ^dynamic and fragment(
          "to_tsvector('english', REPLACE(name, '.', ' ')) @@ to_tsquery(?)",
          ^terms
        ))

      {_, _}, dynamic ->
        dynamic
    end)
  end

  defp query_to_terms(query) do
    query
    |> String.replace(~r/\W/u, " ")
    |> String.split(" ", trim: true)
    |> Enum.map(& &1 <> ":*")
    |> Enum.join(" & ")
  end
end
