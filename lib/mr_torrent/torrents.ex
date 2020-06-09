defmodule MrTorrent.Torrents do
  alias MrTorrent.Repo

  alias MrTorrent.Torrents.Torrent
  alias MrTorrent.Torrents.Access
  alias MrTorrent.Torrents.Announcement
  alias MrTorrent.Torrents.Filter
  alias MrTorrent.Peerlist

  def list_torrents do
    Repo.all(Torrent)
  end

  def list_torrents(%{} = params) do
    Filter.filter_torrents_query(
      query: params["query"],
      category_ids: find_category_ids_for_filter(params["category_id"])
    ) |> Repo.all()
  end

  defp find_category_ids_for_filter(nil), do: nil

  defp find_category_ids_for_filter(category_id)
       when is_number(category_id) do
    find_subcategory_ids(category_id)
  end

  defp find_category_ids_for_filter(category_id)
       when is_binary(category_id) do
    find_category_ids_for_filter(String.to_integer(category_id))
  end

  def get_torrent!(id), do: Repo.one!(Torrent.find_torrent_query(id))
  def get_torrent_by_slug!(slug), do: Repo.one(Torrent.find_torrent_by_slug_query(slug))

  def new_torrent do
    Torrent.new_changeset(%Torrent{})
  end

  def create_torrent(params, %MrTorrent.Accounts.User{} = user) do
    Torrent.create_from_file(params, user)
    |> Repo.insert()
  end

  def delete_torrent(%Torrent{} = torrent) do
    Repo.delete(torrent)
  end

  def generate_torrent_for_user(%Plug.Conn{} = conn, %Torrent{} = torrent, user) do
    access = find_or_create_access(torrent, user)

    comment = "MrTorrent Tracker"

    Torrent.generate_torrent_file(
      torrent,
      announce_url(conn, access.token),
      comment
    )
  end

  def find_or_create_access(torrent, user) do
    {:ok, query} = Access.find_for_torrent_and_user_query(torrent, user)

    if access = Repo.one(query) do
      access
    else
      Access.generate_access(torrent, user)
      |> Repo.insert!()
    end
  end

  defp announce_url(%Plug.Conn{scheme: scheme, host: host, port: port}, token) do
    encoded_token = Access.encode_token(token)

    %URI{
      scheme: Atom.to_string(scheme),
      host: host,
      port: port,
      path: "/announce/#{encoded_token}"
    }
    |> URI.to_string()
  end

  def download_count(%Torrent{} = torrent) do
    Access.download_count_query(torrent)
    |> Repo.one()
  end

  @announce_interval 60 * 5

  def announce(ip, token, params) do
    case decode_and_verify_token(token) do
      {:ok, access, _user, torrent} ->
        # TODO: Check if user is still active
        Announcement.generate(ip, access, params)
        |> Repo.insert!()

        {:ok, peers} = Peerlist.announce(torrent, ip, params)

        {:ok, %{interval: @announce_interval, peers: peers}}

      {:error, message} ->
        {:error, message}
    end
  end

  defp decode_and_verify_token(token) do
    with {:ok, raw_token} <- Access.decode_token(token),
         {:ok, query} <- Access.verify_token_query(raw_token),
         [access, user, torrent] <- Repo.one(query) do
      {:ok, access, user, torrent}
    else
      _ ->
        {:error, "Could not verify token"}
    end
  end

  alias MrTorrent.Torrents.Category

  def category_tree do
    build_category_tree(Repo.all(Category), %{id: nil})
  end

  defp build_category_tree(categories, category) do
    categories
    |> Enum.filter(fn (cat) -> cat.parent_id == category.id end)
    |> Enum.reduce(%{}, fn (child, acc) ->
         Map.put(acc, child, build_category_tree(categories, child))
       end)
  end

  def find_subcategory_ids(category_id) do
    categories = Repo.all(Category)
    category = Enum.find(categories, & &1.id == category_id)

    find_category_children(categories, category)
    |> List.flatten
    |> Enum.sort
  end

  def find_category_children(categories, nil), do: []

  def find_category_children(categories, category) do
    children =
      categories
      |> Enum.filter(& &1.parent_id == category.id)
      |> Enum.map(fn child -> find_category_children(categories, child) end)

    if Enum.empty?(children) do
      [category.id]
    else
      [category.id | children]
    end
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
