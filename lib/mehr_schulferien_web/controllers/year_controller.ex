defmodule MehrSchulferienWeb.YearController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Calendar
  alias MehrSchulferien.Location
  alias MehrSchulferien.Repo
  alias MehrSchulferien.Calendar.Year
  alias MehrSchulferien.Calendar.Day
  import Ecto.Query

  def index(conn, _params) do
    years = Calendar.list_years()
    render(conn, "index.html", years: years)
  end

  def new(conn, _params) do
    changeset = Calendar.change_year(%Year{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"year" => year_params}) do
    case Calendar.create_year(year_params) do
      {:ok, year} ->
        conn
        |> put_flash(:info, "Year created successfully.")
        |> redirect(to: year_path(conn, :show, year))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "federal_state_id" => federal_state_id}) do
    year = Calendar.get_year!(id)
    federal_state = Location.get_federal_state!(federal_state_id)
    {:ok, starts_on} = Date.from_erl({year.value, 1, 1})
    {:ok, ends_on} = Date.from_erl({year.value, 12, 31})

    months = MehrSchulferien.Collect.calendar_ready_months(starts_on, ends_on, "deutschland", federal_state.slug)

    render(conn, "show-timeperiod.html", year: year,
                                         federal_state: federal_state,
                                         months: months)
  end

  def show(conn, %{"id" => id}) do
    year = Calendar.get_year!(id)
    render(conn, "show.html", year: year)
  end

  def edit(conn, %{"id" => id}) do
    year = Calendar.get_year!(id)
    changeset = Calendar.change_year(year)
    render(conn, "edit.html", year: year, changeset: changeset)
  end

  def update(conn, %{"id" => id, "year" => year_params}) do
    year = Calendar.get_year!(id)

    case Calendar.update_year(year, year_params) do
      {:ok, year} ->
        conn
        |> put_flash(:info, "Year updated successfully.")
        |> redirect(to: year_path(conn, :show, year))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", year: year, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    year = Calendar.get_year!(id)
    {:ok, _year} = Calendar.delete_year(year)

    conn
    |> put_flash(:info, "Year deleted successfully.")
    |> redirect(to: year_path(conn, :index))
  end
end
