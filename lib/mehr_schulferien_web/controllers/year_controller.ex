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
    {:ok, ends_on} = Date.from_erl({year.value, 1, 31}) # FIXME: 31.12.!!!

    # The SQL Query
    #
    #   SELECT days.date_value
    #                ,periods.name
    #                ,periods.federal_state_id
    #                ,periods.country_id
    #            FROM days
    # LEFT OUTER JOIN slots
    #              ON days.id = slots.day_id
    # LEFT OUTER JOIN periods
    #              ON slots.period_id = periods.id
    #             AND ( periods.country_id       = 1
    #                  OR periods.federal_state_id = 1
    #                 )
    #           WHERE days.date_value  >= '2017-01-01'
    #             AND days.date_value  <= '2017-01-31'
    #        ORDER BY days.date_value
    #        ;

    query = from(
                 days in Day,
                 left_join: slots in MehrSchulferien.Calendar.Slot,
                 on: days.id == slots.day_id,
                 left_join: periods in MehrSchulferien.Calendar.Period,
                 on: slots.period_id == periods.id and
                     (periods.country_id == ^federal_state.country_id or
                      periods.federal_state_id == ^federal_state.id),
                 left_join: federal_state in MehrSchulferien.Location.FederalState,
                 on:  periods.federal_state_id == federal_state.id,
                 left_join: country in MehrSchulferien.Location.Country,
                 on:  periods.country_id == country.id,
                 where: days.date_value >= ^starts_on and
                        days.date_value <= ^ends_on,
                 order_by: days.date_value,
                 select: {
                           days.date_value,
                           days.value,
                           days.weekday,
                           periods.id,
                           periods.name,
                           country.id,
                           country.name,
                           federal_state.id,
                           federal_state.name
                         }
                )

    days = Repo.all(query) |> Enum.uniq

    # Fill days with empty elements for the calendar blanks in
    # the first and last line of it.
    #
    head_fill = case elem(List.first(days),2) do
      1 -> nil
      2 -> [{}]
      3 -> [{},{}]
      4 -> [{},{},{}]
      5 -> [{},{},{},{}]
      6 -> [{},{},{},{},{}]
      7 -> [{},{},{},{},{},{}]
    end

    tail_fill = case elem(List.last(days),2) do
      7 -> nil
      6 -> [{}]
      5 -> [{},{}]
      4 -> [{},{},{}]
      3 -> [{},{},{},{}]
      2 -> [{},{},{},{},{}]
      1 -> [{},{},{},{},{},{}]
    end

    days = Enum.concat(head_fill, days)
    days = Enum.concat(days, tail_fill)

    # Chop the tuple in 7 days chunks
    #
    weeks = Enum.chunk_every(days, 7)

    render(conn, "show-timeperiod.html", year: year,
                                         federal_state: federal_state,
                                         weeks: weeks)
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
