defmodule Type do
  def cast(map)
      when is_map(map) do
    for {key, val} <- map, into: %{} do
      {atomize(key), val}
    end
  end

  defp atomize_key(key) when is_string(key), do: String.to_atom(key)
  defp atomize_key(key) when is_atom(key), do: key
  defp atomize_key(_), do: :error
end

IO.inspect(Type.cast(%{"foo" => "bar", "baz" => "waz"}))
IO.inspect(Type.cast(%{foo: "bar", baz: "waz"}))
