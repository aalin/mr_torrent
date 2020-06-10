defmodule MrTorrentWeb.NumberHelper do
  def format_number(number) when is_integer(number), do: format_number(Integer.to_string(number))

  def format_number(string) do
    string
    |> String.reverse()
    |> String.split("", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&(Enum.reverse(&1) |> Enum.join()))
    |> Enum.reverse()
    |> Enum.join(" ")
  end
end
