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
