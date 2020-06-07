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
    Enum.reduce(torrent.files, 0, fn file, acc -> file.length + acc end)
    |> format_file_size
  end

  def autoupdate_torrent_field(torrent_id, field_name, initial_content \\ "") do
    content_tag(:span, initial_content,
      "data-torrent-id": torrent_id,
      "data-torrent-field": field_name
    )
  end
end
