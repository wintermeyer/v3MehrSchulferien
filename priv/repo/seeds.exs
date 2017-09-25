# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MehrSchulferien.Repo.insert!(%MehrSchulferien.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MehrSchulferien.Calendar
alias MehrSchulferien.Location
import Ecto.Query

# Years 2016-2020
#
Enum.each (2016..2020), fn year_number ->
  case Calendar.create_year(%{value: year_number}) do
    {:ok, year} ->
      {:ok, first_day} = Date.from_erl({year_number, 1, 1})
      Enum.each (0..366), fn counter ->
        day = Date.add(first_day, counter)
        case day.year do
          ^year_number ->
            case day.day do
              1 -> {:ok, month} = Calendar.create_month(%{value: day.month, year_id: year.id})
              _ -> query = from m in Calendar.Month, where: m.value == ^day.month, where: m.year_id == ^year.id
                   month = MehrSchulferien.Repo.one(query)
            end

            Calendar.create_day(%{value: day.day, year_id: year.id, month_id: month.id })
          _ -> nil
        end
      _ -> nil
    end
  end
end

# Location
#

# Create Germany as a country
#
{:ok, germany} = Location.create_country(%{name: "Deutschland"})

# Create the federal states of Germany
#
{:ok, badenwuerttemberg} = Location.create_federal_state(%{name: "Baden-Württemberg", code: "BW", country_id: germany.id})
{:ok, bayern} = Location.create_federal_state(%{name: "Bayern", code: "BY", country_id: germany.id})
{:ok, berlin} = Location.create_federal_state(%{name: "Berlin", code: "BE", country_id: germany.id})
{:ok, brandenburg} = Location.create_federal_state(%{name: "Brandenburg", code: "BB", country_id: germany.id})
{:ok, bremen} = Location.create_federal_state(%{name: "Bremen", code: "HB", country_id: germany.id})
{:ok, hamburg} = Location.create_federal_state(%{name: "Hamburg", code: "HH", country_id: germany.id})
{:ok, hessen} = Location.create_federal_state(%{name: "Hessen", code: "HE", country_id: germany.id})
{:ok, mecklenburgvorpommern} = Location.create_federal_state(%{name: "Mecklenburg-Vorpommern", code: "MV", country_id: germany.id})
{:ok, niedersachsen} = Location.create_federal_state(%{name: "Niedersachsen", code: "NI", country_id: germany.id})
{:ok, nordrheinwestfalen} = Location.create_federal_state(%{name: "Nordrhein-Westfalen", code: "NW", country_id: germany.id})
{:ok, rheinlandpfalz} = Location.create_federal_state(%{name: "Rheinland-Pfalz", code: "RP", country_id: germany.id})
{:ok, saarland} = Location.create_federal_state(%{name: "Saarland", code: "SL", country_id: germany.id})
{:ok, sachsen} = Location.create_federal_state(%{name: "Sachsen", code: "SN", country_id: germany.id})
{:ok, sachsenanhalt} = Location.create_federal_state(%{name: "Sachsen-Anhalt", code: "ST", country_id: germany.id})
{:ok, schleswigholstein} = Location.create_federal_state(%{name: "Schleswig-Holstein", code: "SH", country_id: germany.id})
{:ok, thueringen} = Location.create_federal_state(%{name: "Thüringen", code: "TH", country_id: germany.id})
