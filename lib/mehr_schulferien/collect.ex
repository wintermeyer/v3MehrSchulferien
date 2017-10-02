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
           |> convert_to_maps
           |> inject_list_of_vacation_periods
           |> inject_list_of_bank_holiday_periods
  end

  def convert_to_maps(months) do
    for month <- months do
      %{month: month}
    end
  end

  def inject_list_of_vacation_periods(months) do
    for month <- months do
      school_vacation_periods =
        for week <- month[:month] do
          for day <- week do
            unless day == {} do
              for period <- day[:periods] do
                {period_data, country, federal_state} = period
                if period_data.category == "Schulferien" do
                  period_data
                end
              end
            end
          end
        end |> List.flatten |> Enum.uniq |> Enum.filter(& !is_nil(&1))

      Map.put_new(month, :school_vacation_periods, school_vacation_periods)
    end
  end

  def inject_list_of_bank_holiday_periods(months) do
    for month <- months do
      bank_holiday_periods =
        for week <- month[:month] do
          for day <- week do
            unless day == {} do
              for period <- day[:periods] do
                {period_data, country, federal_state} = period
                if period_data.category == "Gesetzlicher Feiertag" do
                  period_data
                end
              end
            end
          end
        end |> List.flatten |> Enum.uniq |> Enum.filter(& !is_nil(&1))

      Map.put_new(month, :bank_holiday_periods, bank_holiday_periods)
    end
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
    raw_days(starts_on, ends_on, country_id, federal_state_id, city_id, school_id)
    |> Enum.uniq
    |> Enum.group_by(fn {date, _, _, _} -> date end, fn {_, period, country, federal_state} -> {period, country, federal_state} end)
    |> Enum.map(fn {date, periods} -> date
      |> Map.put(:periods, Enum.reject(periods, fn(x) -> x == {nil,nil,nil} end)) end)
    |> Enum.sort_by(fn x -> Date.to_string(x[:date_value]) end)
    |> inject_css_class
  end

  def inject_css_class(days) do
    for day <- days do
      categories = for period <- day.periods do
        {period_data, country, federal_state} = period
        period_data.category
      end |> List.flatten

      css_class = case {
             Enum.member?(categories, "Wochenende"),
             Enum.member?(categories, "Schulferien"),
             Enum.member?(categories, "Gesetzlicher Feiertag")
           } do
        {_, _, true} -> "info"
        {_, true, _} -> "success"
        {true, _, _} -> "active"
        {_, _, _} -> ""
      end

      Map.put_new(day, :css_class, css_class)
    end
  end

  def raw_days(starts_on \\ nil, ends_on \\ nil, country_id \\ "deutschland", federal_state_id \\ nil, city_id \\ nil, school_id \\ nil) do
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
                  map(periods, [:id, :name, :slug, :category, :starts_on, :ends_on]),
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
                  map(periods, [:id, :name, :slug, :category, :starts_on, :ends_on]),
                  map(country, [:id, :name, :slug]),
                  map(federal_state, [:id, :name, :slug])
                }
          )
       # TODO: city and school
    end

    Repo.all(query)
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
    {:ok, ends_on} = case {ends_on.month, Date.leap_year?(ends_on)} do
      {1, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {2, false} -> Date.from_erl({ends_on.year, ends_on.month, 28})
      {2, true} -> Date.from_erl({ends_on.year, ends_on.month, 29})
      {3, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {4, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {5, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {6, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {7, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {8, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {9, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {10, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {11, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {12, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
    end
    {starts_on, ends_on}
  end

end
