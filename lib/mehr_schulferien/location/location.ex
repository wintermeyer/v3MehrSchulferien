defmodule MehrSchulferien.Location do
  @moduledoc """
  The Location context.
  """

  import Ecto.Query, warn: false
  alias MehrSchulferien.Repo

  alias MehrSchulferien.Location.Country

  @doc """
  Returns the list of countries.

  ## Examples

      iex> list_countries()
      [%Country{}, ...]

  """
  def list_countries do
    Repo.all(Country)
  end

  @doc """
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(id), do: Repo.get!(Country, id)

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country.

  ## Examples

      iex> update_country(country, %{field: new_value})
      {:ok, %Country{}}

      iex> update_country(country, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{source: %Country{}}

  """
  def change_country(%Country{} = country) do
    Country.changeset(country, %{})
  end

  alias MehrSchulferien.Location.FederalState

  @doc """
  Returns the list of federal_states.

  ## Examples

      iex> list_federal_states()
      [%FederalState{}, ...]

  """
  def list_federal_states do
    Repo.all(FederalState)
  end

  @doc """
  Gets a single federal_state.

  Raises `Ecto.NoResultsError` if the Federal state does not exist.

  ## Examples

      iex> get_federal_state!(123)
      %FederalState{}

      iex> get_federal_state!(456)
      ** (Ecto.NoResultsError)

  """
  def get_federal_state!(id), do: Repo.get!(FederalState, id)

  @doc """
  Creates a federal_state.

  ## Examples

      iex> create_federal_state(%{field: value})
      {:ok, %FederalState{}}

      iex> create_federal_state(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_federal_state(attrs \\ %{}) do
    %FederalState{}
    |> FederalState.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a federal_state.

  ## Examples

      iex> update_federal_state(federal_state, %{field: new_value})
      {:ok, %FederalState{}}

      iex> update_federal_state(federal_state, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_federal_state(%FederalState{} = federal_state, attrs) do
    federal_state
    |> FederalState.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a FederalState.

  ## Examples

      iex> delete_federal_state(federal_state)
      {:ok, %FederalState{}}

      iex> delete_federal_state(federal_state)
      {:error, %Ecto.Changeset{}}

  """
  def delete_federal_state(%FederalState{} = federal_state) do
    Repo.delete(federal_state)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking federal_state changes.

  ## Examples

      iex> change_federal_state(federal_state)
      %Ecto.Changeset{source: %FederalState{}}

  """
  def change_federal_state(%FederalState{} = federal_state) do
    FederalState.changeset(federal_state, %{})
  end

  alias MehrSchulferien.Location.City

  @doc """
  Returns the list of cities.

  ## Examples

      iex> list_cities()
      [%City{}, ...]

  """
  def list_cities do
    Repo.all(City)
  end

  @doc """
  Gets a single city.

  Raises `Ecto.NoResultsError` if the City does not exist.

  ## Examples

      iex> get_city!(123)
      %City{}

      iex> get_city!(456)
      ** (Ecto.NoResultsError)

  """
  def get_city!(id), do: Repo.get!(City, id)

  @doc """
  Creates a city.

  ## Examples

      iex> create_city(%{field: value})
      {:ok, %City{}}

      iex> create_city(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_city(attrs \\ %{}) do
    %City{}
    |> City.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a city.

  ## Examples

      iex> update_city(city, %{field: new_value})
      {:ok, %City{}}

      iex> update_city(city, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_city(%City{} = city, attrs) do
    city
    |> City.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a City.

  ## Examples

      iex> delete_city(city)
      {:ok, %City{}}

      iex> delete_city(city)
      {:error, %Ecto.Changeset{}}

  """
  def delete_city(%City{} = city) do
    Repo.delete(city)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking city changes.

  ## Examples

      iex> change_city(city)
      %Ecto.Changeset{source: %City{}}

  """
  def change_city(%City{} = city) do
    City.changeset(city, %{})
  end

  alias MehrSchulferien.Location.School

  @doc """
  Returns the list of schools.

  ## Examples

      iex> list_schools()
      [%School{}, ...]

  """
  def list_schools do
    Repo.all(School)
  end

  @doc """
  Gets a single school.

  Raises `Ecto.NoResultsError` if the School does not exist.

  ## Examples

      iex> get_school!(123)
      %School{}

      iex> get_school!(456)
      ** (Ecto.NoResultsError)

  """
  def get_school!(id), do: Repo.get!(School, id)

  @doc """
  Creates a school.

  ## Examples

      iex> create_school(%{field: value})
      {:ok, %School{}}

      iex> create_school(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_school(attrs \\ %{}) do
    %School{}
    |> School.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a school.

  ## Examples

      iex> update_school(school, %{field: new_value})
      {:ok, %School{}}

      iex> update_school(school, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_school(%School{} = school, attrs) do
    school
    |> School.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a School.

  ## Examples

      iex> delete_school(school)
      {:ok, %School{}}

      iex> delete_school(school)
      {:error, %Ecto.Changeset{}}

  """
  def delete_school(%School{} = school) do
    Repo.delete(school)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking school changes.

  ## Examples

      iex> change_school(school)
      %Ecto.Changeset{source: %School{}}

  """
  def change_school(%School{} = school) do
    School.changeset(school, %{})
  end
end
