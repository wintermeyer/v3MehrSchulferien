defmodule MehrSchulferien.Location.FederalStateSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end
