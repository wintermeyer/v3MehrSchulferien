# Script for populating the database with cities and schools.
# You can run it as:
#
#     mix run priv/repo/school-vacation-seeds.exs

alias MehrSchulferien.Repo
import Ecto.Query

vacation_dates = File.stream!("priv/repo/school-vacation-2017-2020.csv") |> CSV.decode(headers: true) |> Enum.to_list

for line <- vacation_dates do
  {:ok, vacation_date} = line

  query = from f in MehrSchulferien.Location.FederalState, where: f.name == ^vacation_date["Bundesland"]
  federal_state = Repo.one(query)

  MehrSchulferien.Calendar.create_period(%{starts_on: vacation_date["Start"], ends_on: vacation_date["End"], name: vacation_date["Type"], federal_state_id: federal_state.id, category: "Schulferien", source: "https://www.kmk.org/service/ferien.html"})
end
