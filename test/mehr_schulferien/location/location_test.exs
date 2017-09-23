defmodule MehrSchulferien.LocationTest do
  use MehrSchulferien.DataCase

  alias MehrSchulferien.Location

  describe "countries" do
    alias MehrSchulferien.Location.Country

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def country_fixture(attrs \\ %{}) do
      {:ok, country} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Location.create_country()

      country
    end

    test "list_countries/0 returns all countries" do
      country = country_fixture()
      assert Location.list_countries() == [country]
    end

    test "get_country!/1 returns the country with given id" do
      country = country_fixture()
      assert Location.get_country!(country.id) == country
    end

    test "create_country/1 with valid data creates a country" do
      assert {:ok, %Country{} = country} = Location.create_country(@valid_attrs)
      assert country.name == "some name"
      assert country.slug == "some slug"
    end

    test "create_country/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Location.create_country(@invalid_attrs)
    end

    test "update_country/2 with valid data updates the country" do
      country = country_fixture()
      assert {:ok, country} = Location.update_country(country, @update_attrs)
      assert %Country{} = country
      assert country.name == "some updated name"
      assert country.slug == "some updated slug"
    end

    test "update_country/2 with invalid data returns error changeset" do
      country = country_fixture()
      assert {:error, %Ecto.Changeset{}} = Location.update_country(country, @invalid_attrs)
      assert country == Location.get_country!(country.id)
    end

    test "delete_country/1 deletes the country" do
      country = country_fixture()
      assert {:ok, %Country{}} = Location.delete_country(country)
      assert_raise Ecto.NoResultsError, fn -> Location.get_country!(country.id) end
    end

    test "change_country/1 returns a country changeset" do
      country = country_fixture()
      assert %Ecto.Changeset{} = Location.change_country(country)
    end
  end

  describe "federal_states" do
    alias MehrSchulferien.Location.FederalState

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def federal_state_fixture(attrs \\ %{}) do
      {:ok, federal_state} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Location.create_federal_state()

      federal_state
    end

    test "list_federal_states/0 returns all federal_states" do
      federal_state = federal_state_fixture()
      assert Location.list_federal_states() == [federal_state]
    end

    test "get_federal_state!/1 returns the federal_state with given id" do
      federal_state = federal_state_fixture()
      assert Location.get_federal_state!(federal_state.id) == federal_state
    end

    test "create_federal_state/1 with valid data creates a federal_state" do
      assert {:ok, %FederalState{} = federal_state} = Location.create_federal_state(@valid_attrs)
      assert federal_state.name == "some name"
      assert federal_state.slug == "some slug"
    end

    test "create_federal_state/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Location.create_federal_state(@invalid_attrs)
    end

    test "update_federal_state/2 with valid data updates the federal_state" do
      federal_state = federal_state_fixture()
      assert {:ok, federal_state} = Location.update_federal_state(federal_state, @update_attrs)
      assert %FederalState{} = federal_state
      assert federal_state.name == "some updated name"
      assert federal_state.slug == "some updated slug"
    end

    test "update_federal_state/2 with invalid data returns error changeset" do
      federal_state = federal_state_fixture()
      assert {:error, %Ecto.Changeset{}} = Location.update_federal_state(federal_state, @invalid_attrs)
      assert federal_state == Location.get_federal_state!(federal_state.id)
    end

    test "delete_federal_state/1 deletes the federal_state" do
      federal_state = federal_state_fixture()
      assert {:ok, %FederalState{}} = Location.delete_federal_state(federal_state)
      assert_raise Ecto.NoResultsError, fn -> Location.get_federal_state!(federal_state.id) end
    end

    test "change_federal_state/1 returns a federal_state changeset" do
      federal_state = federal_state_fixture()
      assert %Ecto.Changeset{} = Location.change_federal_state(federal_state)
    end
  end
end
