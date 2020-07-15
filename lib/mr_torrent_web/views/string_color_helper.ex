defmodule MrTorrentWeb.StringColorHelper do
  def hsl_color_from_string(string) do
    degrees =
      (get_float(string) * 360)
      |> Float.round(2)

    "hsl(#{degrees}, 100%, 50%)"
  end

  defp get_float(string) do
    :crypto.hash(:sha, string)
    |> :binary.bin_to_list()
    |> Enum.map(&(&1 / 255.0))
    |> Enum.sum()
    |> fract
  end

  defp fract(float) do
    float - trunc(float)
  end
end
