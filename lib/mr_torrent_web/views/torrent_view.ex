defmodule MrTorrentWeb.TorrentView do
  use MrTorrentWeb, :view

  alias MrTorrentWeb.StringColorHelper

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

  def tag_list(conn, tags) do
    content_tag(:ul, class: "tag-list") do
      Enum.map(tags, fn tag ->
        content_tag(:li) do
          color = StringColorHelper.hsl_color_from_string(tag.name)
          link(tag.name, to: Routes.torrent_path(conn, :index, tag: tag.name), style: "background: #{color};")
        end
      end)
    end
  end

  def download_torrent_link(conn, torrent, text \\ "Download", opts \\ []) do
    title = Keyword.get(opts, :title, "Download .torrent")
    link(text, to: Routes.torrent_path(conn, :download, torrent), download: "", title: title)
  end

  def autoupdate_torrent_field(torrent_id, field_name, initial_content \\ "") do
    content_tag(:span, initial_content,
      "data-torrent-id": torrent_id,
      "data-torrent-field": field_name
    )
  end

  def category_link(category) do
    case category do
      %MrTorrent.Torrents.Category{} ->
        link(to: "?category_id=#{category.id}", do: category.name)

      _ ->
        "N/A"
    end
  end

  def categories_for_filter_select do
    traverse_category_tree_for_filter_select(MrTorrent.Torrents.category_tree())
  end

  defp traverse_category_tree_for_filter_select(tree, path \\ []) do
    tree
    |> Enum.sort_by(fn {category, _} -> category.name end)
    |> Enum.reduce([], fn {category, children}, acc ->
      item = {
        String.duplicate("— ", Enum.count(path)) <> category.name,
        category.id
      }

      if Enum.empty?(children) do
        [item | acc]
      else
        current_path = path ++ [category.name]
        acc ++ [item | traverse_category_tree_for_filter_select(children, current_path)]
      end
    end)
  end

  def categories_for_select do
    build_optgroup_list(MrTorrent.Torrents.category_tree())
  end

  defp build_optgroup_list(tree, path \\ []) do
    tree
    |> Enum.sort_by(fn {category, _} -> category.name end)
    |> Enum.reduce([], fn
      {category, []}, acc ->
        acc ++ [{category.name, category.id}]

      {category, children}, acc ->
        current_path = path ++ [category.name]
        name = Enum.join(current_path, " / ")

        {leaves, nodes} =
          Enum.split_with(children, fn {_child, grandchildren} ->
            Enum.empty?(grandchildren)
          end)

        leaves_list = build_optgroup_list(leaves, current_path)
        nodes_list = build_optgroup_list(nodes, current_path)

        acc ++ [{name, leaves_list} | nodes_list]
    end)
  end
end
