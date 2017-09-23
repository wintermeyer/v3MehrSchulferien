defmodule MehrSchulferien.CalendarTest do
  use MehrSchulferien.DataCase

  alias MehrSchulferien.Calendar

  describe "years" do
    alias MehrSchulferien.Calendar.Year

    @valid_attrs %{slug: "some slug", value: 42}
    @update_attrs %{slug: "some updated slug", value: 43}
    @invalid_attrs %{slug: nil, value: nil}

    def year_fixture(attrs \\ %{}) do
      {:ok, year} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Calendar.create_year()

      year
    end

    test "list_years/0 returns all years" do
      year = year_fixture()
      assert Calendar.list_years() == [year]
    end

    test "get_year!/1 returns the year with given id" do
      year = year_fixture()
      assert Calendar.get_year!(year.id) == year
    end

    test "create_year/1 with valid data creates a year" do
      assert {:ok, %Year{} = year} = Calendar.create_year(@valid_attrs)
      assert year.slug == "some slug"
      assert year.value == 42
    end

    test "create_year/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendar.create_year(@invalid_attrs)
    end

    test "update_year/2 with valid data updates the year" do
      year = year_fixture()
      assert {:ok, year} = Calendar.update_year(year, @update_attrs)
      assert %Year{} = year
      assert year.slug == "some updated slug"
      assert year.value == 43
    end

    test "update_year/2 with invalid data returns error changeset" do
      year = year_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendar.update_year(year, @invalid_attrs)
      assert year == Calendar.get_year!(year.id)
    end

    test "delete_year/1 deletes the year" do
      year = year_fixture()
      assert {:ok, %Year{}} = Calendar.delete_year(year)
      assert_raise Ecto.NoResultsError, fn -> Calendar.get_year!(year.id) end
    end

    test "change_year/1 returns a year changeset" do
      year = year_fixture()
      assert %Ecto.Changeset{} = Calendar.change_year(year)
    end
  end

  describe "months" do
    alias MehrSchulferien.Calendar.Month

    @valid_attrs %{slug: "some slug", value: 42}
    @update_attrs %{slug: "some updated slug", value: 43}
    @invalid_attrs %{slug: nil, value: nil}

    def month_fixture(attrs \\ %{}) do
      {:ok, month} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Calendar.create_month()

      month
    end

    test "list_months/0 returns all months" do
      month = month_fixture()
      assert Calendar.list_months() == [month]
    end

    test "get_month!/1 returns the month with given id" do
      month = month_fixture()
      assert Calendar.get_month!(month.id) == month
    end

    test "create_month/1 with valid data creates a month" do
      assert {:ok, %Month{} = month} = Calendar.create_month(@valid_attrs)
      assert month.slug == "some slug"
      assert month.value == 42
    end

    test "create_month/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendar.create_month(@invalid_attrs)
    end

    test "update_month/2 with valid data updates the month" do
      month = month_fixture()
      assert {:ok, month} = Calendar.update_month(month, @update_attrs)
      assert %Month{} = month
      assert month.slug == "some updated slug"
      assert month.value == 43
    end

    test "update_month/2 with invalid data returns error changeset" do
      month = month_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendar.update_month(month, @invalid_attrs)
      assert month == Calendar.get_month!(month.id)
    end

    test "delete_month/1 deletes the month" do
      month = month_fixture()
      assert {:ok, %Month{}} = Calendar.delete_month(month)
      assert_raise Ecto.NoResultsError, fn -> Calendar.get_month!(month.id) end
    end

    test "change_month/1 returns a month changeset" do
      month = month_fixture()
      assert %Ecto.Changeset{} = Calendar.change_month(month)
    end
  end

  describe "days" do
    alias MehrSchulferien.Calendar.Day

    @valid_attrs %{day_of_year: 42, slug: "some slug", value: 42, weekday: 42, weekday_de: "some weekday_de"}
    @update_attrs %{day_of_year: 43, slug: "some updated slug", value: 43, weekday: 43, weekday_de: "some updated weekday_de"}
    @invalid_attrs %{day_of_year: nil, slug: nil, value: nil, weekday: nil, weekday_de: nil}

    def day_fixture(attrs \\ %{}) do
      {:ok, day} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Calendar.create_day()

      day
    end

    test "list_days/0 returns all days" do
      day = day_fixture()
      assert Calendar.list_days() == [day]
    end

    test "get_day!/1 returns the day with given id" do
      day = day_fixture()
      assert Calendar.get_day!(day.id) == day
    end

    test "create_day/1 with valid data creates a day" do
      assert {:ok, %Day{} = day} = Calendar.create_day(@valid_attrs)
      assert day.day_of_year == 42
      assert day.slug == "some slug"
      assert day.value == 42
      assert day.weekday == 42
      assert day.weekday_de == "some weekday_de"
    end

    test "create_day/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendar.create_day(@invalid_attrs)
    end

    test "update_day/2 with valid data updates the day" do
      day = day_fixture()
      assert {:ok, day} = Calendar.update_day(day, @update_attrs)
      assert %Day{} = day
      assert day.day_of_year == 43
      assert day.slug == "some updated slug"
      assert day.value == 43
      assert day.weekday == 43
      assert day.weekday_de == "some updated weekday_de"
    end

    test "update_day/2 with invalid data returns error changeset" do
      day = day_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendar.update_day(day, @invalid_attrs)
      assert day == Calendar.get_day!(day.id)
    end

    test "delete_day/1 deletes the day" do
      day = day_fixture()
      assert {:ok, %Day{}} = Calendar.delete_day(day)
      assert_raise Ecto.NoResultsError, fn -> Calendar.get_day!(day.id) end
    end

    test "change_day/1 returns a day changeset" do
      day = day_fixture()
      assert %Ecto.Changeset{} = Calendar.change_day(day)
    end
  end
end
