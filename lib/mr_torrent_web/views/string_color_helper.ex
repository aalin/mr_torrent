defmodule MrTorrentWeb.StringColorHelper do
  def color_from_string(string) do
    string
    |> get_float()
    |> html_palette()
  end

  def html_palette(float) do
    float
    |> palette()
    |> html_color()
  end

  defp palette(float) do
    for x <- 0..2 do
      palette_color(float, x)
    end
  end

  defp palette_color(float, index) do
    (float + index) * :math.pi + index / 3.0 * :math.pi
    |> :math.sin()
    |> :math.pow(2)
  end

  defp get_float(string) do
    :crypto.hash(:md5, string)
    |> :binary.bin_to_list
    |> Enum.slice(0, 5)
    |> Enum.map(& &1 / 256.0)
    |> Enum.reduce(0.0, fn x, acc -> x + acc end)
    |> fract
  end

  defp fract(float) do
    float - trunc(float)
  end

  defp html_color(float_color) do
    "##{hexify(float_color)}"
  end

  defp hexify(list)
       when is_list(list) do
    list
    |> Enum.map(&hexify/1)
    |> Enum.join()
  end

  defp hexify(float)
       when is_float(float) do
    hexify(trunc(float * 255))
  end

  defp hexify(number)
       when is_integer(number) do
    number
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
  end
end
