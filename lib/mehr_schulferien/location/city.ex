defmodule MehrSchulferien.Location.City do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Location.City
  alias MehrSchulferien.Location.CitySlug


  schema "cities" do
    field :name, :string
    field :slug, :string
    field :zip_code, :string
    belongs_to :country, MehrSchulferien.Location.Country
    belongs_to :federal_state, MehrSchulferien.Location.FederalState

    timestamps()
  end

  @doc false
  def changeset(%City{} = city, attrs) do
    city
    |> cast(attrs, [:name, :zip_code, :slug, :country_id, :federal_state_id])
    |> validate_required([:name, :zip_code, :country_id, :federal_state_id])
    |> set_slug
    |> unique_constraint(:slug)
    |> assoc_constraint(:country)
    |> assoc_constraint(:federal_state)
  end

  defp set_slug(changeset) do
    slug = get_field(changeset, :slug)

    case slug do
      nil -> changeset
             |> CitySlug.maybe_generate_slug
             |> CitySlug.unique_constraint
      _ -> changeset
    end
  end
end
