defmodule MrTorrent.PaginatorTest do
  use MrTorrent.DataCase

  import MrTorrent.AccountsFixtures

  alias MrTorrent.Accounts.User
  alias MrTorrent.Paginator

  describe "when the page is nil" do
    test "sets the page to the first page" do
      create_users(1)

      paginator = Paginator.paginate(User, nil)

      assert paginator.current_page == 1
    end
  end

  describe "when the page is a string" do
    test "sets the page to an integer" do
      create_users(1)

      paginator = Paginator.paginate(User, "1")

      assert paginator.current_page == 1
    end
  end

  test "paginate as 25 results per page" do
    create_users(28)

    paginator_first_page = Paginator.paginate(User, 1)
    assert length(paginator_first_page.list) == 25

    paginator_second_page = Paginator.paginate(User, 2)
    assert length(paginator_second_page.list) == 3
  end

  test "prints pagination info" do
    users = create_users(10)

    paginator = Paginator.paginate(User, 1)

    assert paginator.current_page == 1
    assert paginator.results_per_page == 25
    assert paginator.total_pages == 1
    assert paginator.total_results == 10

    Enum.each(users, fn user ->
      assert user in paginator.list
    end)
  end

  defp create_users(quantity) do
    for _n <- 1..quantity do
      user_fixture()
    end
  end
end
