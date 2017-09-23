defmodule MehrSchulferien.Location.Country do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Location.Country
  alias MehrSchulferien.Location.CountrySlug


  schema "countries" do
    field :name, :string
    field :slug, CountrySlug.Type

    timestamps()
  end

  @doc false
  def changeset(%Country{} = country, attrs) do
    country
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> set_slug
    |> unique_constraint(:slug)
  end

  defp set_slug(changeset) do
    slug = get_field(changeset, :slug)

    case slug do
      nil -> changeset
             |> CountrySlug.maybe_generate_slug
             |> CountrySlug.unique_constraint
      _ -> changeset
    end
  end
end
