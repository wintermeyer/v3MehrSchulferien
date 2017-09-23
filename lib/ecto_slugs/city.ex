defmodule MehrSchulferien.Location.CitySlug do
  use EctoAutoslugField.Slug, from: [:zip_code, :name], to: :slug
end
