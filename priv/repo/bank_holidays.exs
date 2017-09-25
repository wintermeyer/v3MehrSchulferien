# Populate the database with weekends and bankholidays
#
#     mix run priv/repo/bank_holidays.exs

alias MehrSchulferien.Calendar
alias MehrSchulferien.Location.Country
alias MehrSchulferien.Location.FederalState
alias MehrSchulferien.Repo
import Ecto.Query

defmodule Holiday do
  def create_single_bank_holiday(date, name, location, source \\ "") do
    case location do
      "Deutschland" -> query = from f in Country, where: f.name == ^location
                       country = Repo.one(query)
                       Calendar.create_period(%{starts_on: date, ends_on: date, name: name, country_id: country.id, category: "Gesetzlicher Feiertag", source: source})
      _ -> query = from f in FederalState, where: f.name == ^location
           federal_state = Repo.one(query)
           Calendar.create_period(%{starts_on: date, ends_on: date, name: name, federal_state_id: federal_state.id, category: "Gesetzlicher Feiertag", source: source})
    end
  end

  def create_single_no_school(date, name, location, source \\ "") do
    case location do
      "Deutschland" -> query = from f in Country, where: f.name == ^location
                       country = Repo.one(query)
                       Calendar.create_period(%{starts_on: date, ends_on: date, name: name, country_id: country.id, source: source, category: "Schulfrei"})
      _ -> query = from f in FederalState, where: f.name == ^location
           federal_state = Repo.one(query)
           Calendar.create_period(%{starts_on: date, ends_on: date, name: name, federal_state_id: federal_state.id, source: source, category: "Schulfrei"})
    end
  end
end

query = from f in Country, where: f.name == "Deutschland"
deutschland = Repo.one(query)

# Wochenenden
#
for year <- (2016..2020) do
  # Create holiday entries for sundays
  #
  {:ok, start_date} = Date.from_erl({year, 1, 1})
  {:ok, end_date} = Date.from_erl({year, 12, 31})

  for date <- Date.range(start_date, end_date) do
    case Date.day_of_week(date) do
      6 -> Calendar.create_period(%{starts_on: date, ends_on: date, name: "Samstag", country_id: deutschland.id, category: "Wochenende"})
      7 -> Calendar.create_period(%{starts_on: date, ends_on: date, name: "Sonntag", country_id: deutschland.id, category: "Wochenende"})
      _ ->
    end
  end
end

Holiday.create_single_bank_holiday("2016-10-31", "Reformationstag", "Baden-Württemberg", "http://www.km-bw.de/,Lde_DE/Startseite/Service/Ferien?QUERYSTRING=ferien")
Holiday.create_single_bank_holiday("2017-10-31", "Reformationstag", "Baden-Württemberg", "http://www.km-bw.de/,Lde_DE/Startseite/Service/Ferien?QUERYSTRING=ferien")
Holiday.create_single_bank_holiday("2018-10-31", "Reformationstag", "Baden-Württemberg", "http://www.km-bw.de/,Lde_DE/Startseite/Service/Ferien?QUERYSTRING=ferien")
Holiday.create_single_bank_holiday("2019-10-31", "Reformationstag", "Baden-Württemberg", "http://www.km-bw.de/,Lde_DE/Startseite/Service/Ferien?QUERYSTRING=ferien")

# bewegliche gesetzliche Feiertage
#
bank_holidays = [
  ["Gründonnerstag", ["2016-03-24", "2017-04-13", "2018-03-29", "2019-04-18", "2020-04-09"]],
  ["Karfreitag", ["2016-03-25", "2017-04-14", "2018-03-30", "2019-04-19", "2020-04-10"]],
  ["Ostersonntag", ["2016-03-27", "2017-04-16", "2018-04-01", "2019-04-21", "2020-04-12"]],
  ["Ostermontag", ["2016-03-28", "2017-04-17", "2018-04-02", "2019-04-22", "2020-04-13"]],
  ["Christi Himmelfahrt", ["2016-05-05", "2017-05-25", "2018-05-10", "2019-05-30", "2020-05-21"]],
  ["Pfingstsonntag", ["2016-05-15", "2017-06-04", "2018-05-20", "2019-06-09", "2020-05-31"]],
  ["Pfingstmontag", ["2016-05-16", "2017-05-06", "2018-05-21", "2019-06-10", "2020-06-01"]],
  ["Fronleichnam", ["2016-05-26", "2017-06-15", "2018-05-31", "2019-06-20", "2020-06-11"]]
]
Enum.each bank_holidays, fn bank_holiday ->
  [name, dates] = bank_holiday
  Enum.each dates, fn date ->
    Holiday.create_single_bank_holiday(date, name, "Deutschland", "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")
  end
end

bank_holidays = [
  ["Sachsen", "Buß- und Bettag", ["2016-11-16", "2017-11-22", "2018-11-21", "2019-11-20", "2020-11-18"]]
]
Enum.each bank_holidays, fn bank_holiday ->
  [federal_state, name, dates] = bank_holiday
  Enum.each dates, fn date ->
    Holiday.create_single_bank_holiday(date, name, federal_state, "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")
  end
end

no_school_days = [
  ["Bayern", "Buß- und Bettag", ["2016-11-16", "2017-11-22", "2018-11-21", "2019-11-20", "2020-11-18"]]
]
Enum.each no_school_days, fn holiday ->
  [federal_state, name, dates] = holiday
  Enum.each dates, fn date ->
    Holiday.create_single_no_school(date, name, federal_state, "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")
  end
end

# nicht bewegliche gesetzliche Feiertage
#
bank_holidays = [
  ["01-01", "Neujahr"],
  ["05-01", "1. Mai"],
  ["10-03", "Tag der Deutschen Einheit"],
  ["12-25", "1. Weihnachtstag"],
  ["12-26", "2. Weihnachtstag"]
]
Enum.each bank_holidays, fn bank_holiday ->
  [date, name] = bank_holiday
  Enum.each (2016..2020), fn year ->
    date = Integer.to_string(year) <> "-" <> date
    Holiday.create_single_bank_holiday(date, name, "Deutschland", "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")
  end
end

# Der 31. Oktober 2017 wird im Gedenken an das 500. Jubiläum des
# Beginns der Reformation einmalig als gesamtdeutscher Feiertag begangen
Holiday.create_single_bank_holiday("2017-10-31", "Reformationstag", "Deutschland", "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")

bank_holidays = [
  ["Baden-Württemberg", "Heilige Drei Könige", ["2016-01-06", "2017-01-06", "2018-01-06", "2019-01-06", "2020-01-06"]],
  ["Bayern", "Heilige Drei Könige", ["2016-01-06", "2017-01-06", "2018-01-06", "2019-01-06", "2020-01-06"]],
  ["Sachsen-Anhalt", "Heilige Drei Könige", ["2016-01-06", "2017-01-06", "2018-01-06", "2019-01-06", "2020-01-06"]],
  ["Brandenburg", "Reformationstag", ["2016-10-31", "2017-10-31", "2018-10-31", "2019-10-31", "2020-10-31"]],
  ["Mecklenburg-Vorpommern", "Reformationstag", ["2016-10-31", "2017-10-31", "2018-10-31", "2019-10-31", "2020-10-31"]],
  ["Sachsen", "Reformationstag", ["2016-10-31", "2017-10-31", "2018-10-31", "2019-10-31", "2020-10-31"]],
  ["Sachsen-Anhalt", "Reformationstag", ["2016-10-31", "2017-10-31", "2018-10-31", "2019-10-31", "2020-10-31"]],
  ["Thüringen", "Reformationstag", ["2016-10-31", "2017-10-31", "2018-10-31", "2019-10-31", "2020-10-31"]],
  ["Baden-Württemberg", "Allerheiligen", ["2016-11-01", "2017-11-01", "2018-11-01", "2019-11-01", "2020-11-01"]],
  ["Bayern", "Allerheiligen", ["2016-11-01", "2017-11-01", "2018-11-01", "2019-11-01", "2020-11-01"]],
  ["Nordrhein-Westfalen", "Allerheiligen", ["2016-11-01", "2017-11-01", "2018-11-01", "2019-11-01", "2020-11-01"]],
  ["Rheinland-Pfalz", "Allerheiligen", ["2016-11-01", "2017-11-01", "2018-11-01", "2019-11-01", "2020-11-01"]],
  ["Saarland", "Allerheiligen", ["2016-11-01", "2017-11-01", "2018-11-01", "2019-11-01", "2020-11-01"]],
]
Enum.each bank_holidays, fn bank_holiday ->
  [federal_state, name, dates] = bank_holiday
  Enum.each dates, fn date ->
    Holiday.create_single_bank_holiday(date, name, federal_state, "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")
  end
end

no_school_days = [
  ["Bayern", "Mariä Himmelfahrt", ["2016-08-15", "2017-08-15", "2018-08-15", "2019-08-15", "2020-08-15"]]
]
Enum.each no_school_days, fn holiday ->
  [federal_state, name, dates] = holiday
  Enum.each dates, fn date ->
    Holiday.create_single_no_school(date, name, federal_state, "https://de.wikipedia.org/wiki/Gesetzliche_Feiertage_in_Deutschland")
  end
end

# TODO: Mariä Himmelfahrt als Feiertag in manchen bayrischen Gemeinden eintragen (als schulfrei ist er schon eingetragen)
