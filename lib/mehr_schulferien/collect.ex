defmodule MehrSchulferien.Collect do
  alias MehrSchulferien.Calendar
  alias MehrSchulferien.Location
  alias MehrSchulferien.Repo
  alias MehrSchulferien.Calendar.Day
  alias MehrSchulferien.Calendar.Slot
  alias MehrSchulferien.Calendar.Period
  alias MehrSchulferien.Location.Country
  alias MehrSchulferien.Location.FederalState
  alias MehrSchulferien.Location.City
  alias MehrSchulferien.Location.School
  import Ecto.Query, warn: false


  def calendar_ready_months(starts_on \\ nil, ends_on \\ nil, country_id \\ "deutschland", federal_state_id \\ nil, city_id \\ nil, school_id \\ nil) do
    {starts_on, ends_on} = set_default_dates_if_needed(starts_on, ends_on)
    {starts_on, ends_on} = make_sure_its_a_full_month(starts_on, ends_on)

    days = days(starts_on, ends_on, country_id, federal_state_id, city_id, school_id)
           |> chunk_days_to_months
           |> prepare_list_of_months_to_be_displayed
  end

  def chunk_days_to_months(days) do
    days |> Enum.chunk_by(fn %{date_value: %{year: year, month: month}} -> {year, month} end)
  end

  def prepare_list_of_months_to_be_displayed(months) do
    for month <- months do
      prepare_days_of_a_month_to_be_displayed(month)
    end
  end

  def prepare_days_of_a_month_to_be_displayed(days) do
    # Fill days with empty elements for the calendar blanks in
    # the first and last line of it.
    #
    head_fill = case List.first(days)[:weekday] do
      1 -> nil
      2 -> [{}]
      3 -> [{},{}]
      4 -> [{},{},{}]
      5 -> [{},{},{},{}]
      6 -> [{},{},{},{},{}]
      7 -> [{},{},{},{},{},{}]
    end

    tail_fill = case List.last(days)[:weekday] do
      7 -> nil
      6 -> [{}]
      5 -> [{},{}]
      4 -> [{},{},{}]
      3 -> [{},{},{},{}]
      2 -> [{},{},{},{},{}]
      1 -> [{},{},{},{},{},{}]
    end

    days = case {head_fill, tail_fill} do
      {nil, nil} -> days
      {nil, _} -> Enum.concat(days, tail_fill)
      {_, nil} -> Enum.concat(head_fill, days)
      {_, _} -> Enum.concat(Enum.concat(head_fill, days), tail_fill)
    end

    Enum.chunk_every(days, 7)
  end

  def days(starts_on \\ nil, ends_on \\ nil, country_id \\ "deutschland", federal_state_id \\ nil, city_id \\ nil, school_id \\ nil) do
    {starts_on, ends_on} = set_default_dates_if_needed(starts_on, ends_on)

    country = case country_id do
      nil -> nil
      _ -> Location.get_country!(country_id)
    end

    federal_state = case federal_state_id do
      nil -> nil
      _ -> Location.get_federal_state!(federal_state_id)
    end

    city = case city_id do
      nil -> nil
      _ -> Location.get_city!(city_id)
    end

    school = case school_id do
      nil -> nil
      _ -> Location.get_school!(school_id)
    end

    query = case {country, federal_state, city, school} do
      {country, nil, nil, nil} ->
        from(
          days in Day,
          left_join: slots in Slot,
          on: days.id == slots.day_id,
          left_join: periods in Period,
          on: slots.period_id == periods.id and
             (periods.country_id == ^country.id),
          left_join: country in Country,
          on:  periods.country_id == country.id,
          left_join: federal_state in FederalState,
          on:  periods.federal_state_id == federal_state.id,
          where: days.date_value >= ^starts_on and
                days.date_value <= ^ends_on,
          order_by: days.date_value,
          select: {map(days, [:date_value, :value, :weekday]),
                  map(periods, [:id, :name, :slug]),
                  map(country, [:id, :name, :slug]),
                  map(federal_state, [:id, :name, :slug])
                }
          )
      {country, federal_state, nil, nil} ->
        from(
          days in Day,
          left_join: slots in Slot,
          on: days.id == slots.day_id,
          left_join: periods in Period,
          on: slots.period_id == periods.id and
              (periods.country_id == ^federal_state.country_id or
               periods.federal_state_id == ^federal_state.id),
          left_join: country in Country,
          on:  periods.country_id == country.id,
          left_join: federal_state in FederalState,
          on:  periods.federal_state_id == federal_state.id,
          where: days.date_value >= ^starts_on and
                days.date_value <= ^ends_on,
          order_by: days.date_value,
          select: {map(days, [:date_value, :value, :weekday]),
                  map(periods, [:id, :name, :slug]),
                  map(country, [:id, :name, :slug]),
                  map(federal_state, [:id, :name, :slug])
                }
          )
       # TODO: city and school
    end

    Repo.all(query)
    |> Enum.uniq
    |> Enum.group_by(fn {date, _, _, _} -> date end, fn {_, period, country, federal_state} -> {period, country, federal_state} end)
    |> Enum.map(fn {date, periods} -> date
    |> Map.put(:periods, Enum.reject(periods, fn(x) -> x == {nil,nil,nil} end)) end)
    |> Enum.sort_by(fn x -> Date.to_string(x[:date_value]) end)
  end

  def set_default_dates_if_needed(starts_on, ends_on) do
    case {starts_on, ends_on} do
      {nil, _} ->
        {:ok, starts_on} = Date.from_erl({Date.utc_today.year, 1, 1})
        {:ok, ends_on} = Date.from_erl({Date.utc_today.year, 12, 31})
        {starts_on, ends_on}
      {_, nil} ->
        {:ok, ends_on} = Date.from_erl({Date.utc_today.year, 12, 31})
        {starts_on, ends_on}
      {_, _} ->
        {starts_on, ends_on}
    end
  end

  def make_sure_its_a_full_month(starts_on, ends_on) do
    {:ok, starts_on} = Date.from_erl({starts_on.year, starts_on.month, 1})
    ends_on = case {ends_on.month, Date.leap_year?(ends_on)} do
      {1, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      {2, false} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 28})
      {2, true} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 29})
      {3, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      {4, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      {5, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      {6, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      {7, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      {8, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      {9, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      {10, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      {11, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      {12, _} -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      ends_on
    end
    {starts_on, ends_on}
  end

end
