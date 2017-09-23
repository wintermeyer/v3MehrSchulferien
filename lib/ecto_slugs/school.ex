defmodule MehrSchulferien.Location.SchoolSlug do
  use EctoAutoslugField.Slug, from: [:address_zip_code, :name], to: :slug
end
