defmodule MrTorrentWeb.TorrentView do
  use MrTorrentWeb, :view

  @units ["B", "KB", "MB", "GB"]

  def format_file_size(size, exponent \\ 0) do
    if size < :math.pow(1024, exponent + 1) or exponent > 3 do
      formatted_size = :erlang.float_to_binary(size / :math.pow(1024, exponent), decimals: 2)
      unit = Enum.at(@units, exponent)
      "#{formatted_size} #{unit}"
    else
      format_file_size(size, exponent + 1)
    end
  end

  def total_size(torrent) do
    torrent.total_size |> format_file_size
  end

  def autoupdate_torrent_field(torrent_id, field_name, initial_content \\ "") do
    content_tag(:span, initial_content,
      "data-torrent-id": torrent_id,
      "data-torrent-field": field_name
    )
  end

  def categories_for_select do
    traverse_category_tree(MrTorrent.Torrents.category_tree)
    |> Enum.sort_by(fn {path, _id} -> path end)
  end

  defp traverse_category_tree(tree, path \\ []) do
    Enum.reduce(tree, [], fn ({category, children}, acc) ->
      current_path = path ++ [category.name]
      item = {Enum.join(current_path, " / "), category.id}

      if Enum.empty?(children) do
        [item | acc]
      else
        acc ++ traverse_category_tree(children, current_path)
      end
    end)
  end
end
