defmodule MehrSchulferien.Location.CountrySlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end
