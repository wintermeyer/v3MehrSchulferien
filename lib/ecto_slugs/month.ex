defmodule MehrSchulferien.Calendar.MonthSlug do
  use EctoAutoslugField.Slug, from: :value, to: :slug
  import Ecto.Changeset

  alias MehrSchulferien.Calendar
  alias MehrSchulferien.Repo
  import Ecto.Query

  # slug: yyyy-mm
  #
  def build_slug(_sources, changeset) do
    value = get_field(changeset, :value)
    year_id = get_field(changeset, :year_id)

    year = case year_id do
      x when is_integer(x) ->
        query = from y in Calendar.Year, where: y.id == ^year_id
        Repo.one(query)
      _ -> nil
    end

    case [year, value] do
      [nil, _] -> nil
      [_, x] when is_integer(x) and x < 10 -> year.slug <> "-0" <> Integer.to_string(x)
      [_, x] when is_integer(x) -> year.slug <> "-" <> Integer.to_string(x)
      [_, _] -> nil
    end
  end
end
