defmodule MehrSchulferien.Calendar.DaySlug do
  use EctoAutoslugField.Slug, from: :value, to: :slug
  import Ecto.Changeset

  alias MehrSchulferien.Calendar
  alias MehrSchulferien.Repo
  import Ecto.Query

  # slug: yyyy-mm-dd
  #
  def build_slug(_sources, changeset) do
    value = get_field(changeset, :value)
    year_id = get_field(changeset, :year_id)
    month_id = get_field(changeset, :month_id)

    year = case year_id do
      x when is_integer(x) ->
        query = from y in Calendar.Year, where: y.id == ^year_id
        Repo.one(query)
      _ -> nil
    end

    month = case month_id do
      x when is_integer(x) ->
        query = from m in Calendar.Month, where: m.id == ^month_id
        Repo.one(query)
      _ -> nil
    end

    case [year, month, value] do
      [nil, _, _] -> nil
      [_, nil, _] -> nil
      [_, _, x] when is_integer(x) and x < 10 -> month.slug <> "-0" <> Integer.to_string(x)
      [_, _, x] when is_integer(x) -> month.slug <> "-" <> Integer.to_string(x)
      [_, _, _] -> nil
    end
  end
end
