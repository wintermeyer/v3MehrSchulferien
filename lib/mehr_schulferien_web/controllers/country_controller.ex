defmodule MehrSchulferienWeb.CountryController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Location
  alias MehrSchulferien.Location.Country

  def index(conn, _params) do
    countries = Location.list_countries()
    render(conn, "index.html", countries: countries)
  end

  def new(conn, _params) do
    changeset = Location.change_country(%Country{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"country" => country_params}) do
    case Location.create_country(country_params) do
      {:ok, country} ->
        conn
        |> put_flash(:info, "Country created successfully.")
        |> redirect(to: country_path(conn, :show, country))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    country = Location.get_country!(id)
    render(conn, "show.html", country: country)
  end

  def edit(conn, %{"id" => id}) do
    country = Location.get_country!(id)
    changeset = Location.change_country(country)
    render(conn, "edit.html", country: country, changeset: changeset)
  end

  def update(conn, %{"id" => id, "country" => country_params}) do
    country = Location.get_country!(id)

    case Location.update_country(country, country_params) do
      {:ok, country} ->
        conn
        |> put_flash(:info, "Country updated successfully.")
        |> redirect(to: country_path(conn, :show, country))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", country: country, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    country = Location.get_country!(id)
    {:ok, _country} = Location.delete_country(country)

    conn
    |> put_flash(:info, "Country deleted successfully.")
    |> redirect(to: country_path(conn, :index))
  end
end
