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
    {starts_on, ends_on} = case {starts_on, ends_on} do
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

    {:ok, starts_on} = Date.from_erl({starts_on.year, starts_on.month, 1})
    ends_on = case ends_on.month do
      1 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      2 ->
        {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 28})
        {:ok, ends_on} = if Date.add(ends_on, 1).month == 2 do
          Date.from_erl({ends_on.year, ends_on.month, 29})
        else
          Date.from_erl({ends_on.year, ends_on.month, 28})
        end
      3 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      4 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      5 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      6 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      7 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      8 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      9 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      10 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      11 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 30})
      12 -> {:ok, ends_on} = Date.from_erl({ends_on.year, ends_on.month, 31})
      ends_on
    end

    days = calendar_ready_weeks(starts_on, ends_on, country_id, federal_state_id, city_id, school_id)
  end


  def calendar_ready_weeks(starts_on, ends_on, country_id \\ "deutschland", federal_state_id \\ nil, city_id \\ nil, school_id \\ nil) do
    days = days(starts_on, ends_on, country_id, federal_state_id, city_id, school_id)

    # Fill days with empty elements for the calendar blanks in
    # the first and last line of it.
    #
    head_fill = case elem(List.first(days),0)[:weekday] do
      1 -> nil
      2 -> [{}]
      3 -> [{},{}]
      4 -> [{},{},{}]
      5 -> [{},{},{},{}]
      6 -> [{},{},{},{},{}]
      7 -> [{},{},{},{},{},{}]
    end

    tail_fill = case elem(List.last(days),0)[:weekday] do
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
    Enum.chunk_every(days, 7)
  end

  def days(starts_on \\ nil, ends_on \\ nil, country_id \\ "deutschland", federal_state_id \\ nil, city_id \\ nil, school_id \\ nil) do
    {starts_on, ends_on} = case {starts_on, ends_on} do
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
  end

end
