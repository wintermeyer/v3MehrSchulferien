defmodule MehrSchulferien.Location.FederalState do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Location.FederalState
  alias MehrSchulferien.Location.FederalStateSlug


  schema "federal_states" do
    field :name, :string
    field :slug, :string
    belongs_to :country, MehrSchulferien.Location.Country

    timestamps()
  end

  @doc false
  def changeset(%FederalState{} = federal_state, attrs) do
    federal_state
    |> cast(attrs, [:name, :slug, :country_id])
    |> validate_required([:name])
    |> set_slug
    |> unique_constraint(:slug)
    |> assoc_constraint(:country)
  end

  defp set_slug(changeset) do
    slug = get_field(changeset, :slug)

    case slug do
      nil -> changeset
             |> FederalStateSlug.maybe_generate_slug
             |> FederalStateSlug.unique_constraint
      _ -> changeset
    end
  end
end
