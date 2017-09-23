defmodule MehrSchulferien.Calendar.YearSlug do
  use EctoAutoslugField.Slug, from: :value, to: :slug
  import Ecto.Changeset

  # slug: yyyy
  #
  def build_slug(_sources, changeset) do
    value = get_field(changeset, :value)

    case value do
      x when is_integer(x) -> Integer.to_string(x)
      _ -> nil
    end
  end
end
