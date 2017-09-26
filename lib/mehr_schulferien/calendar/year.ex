defmodule MehrSchulferien.Calendar.Year do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Calendar.Year
  alias MehrSchulferien.Calendar.YearSlug

  @derive {Phoenix.Param, key: :slug}
  schema "years" do
    field :value, :integer
    field :slug, YearSlug.Type

    timestamps()
  end

  @doc false
  def changeset(%Year{} = year, attrs) do
    year
    |> cast(attrs, [:value])
    |> validate_required([:value])
    |> unique_constraint(:value)
    |> validate_inclusion(:value, 2016..2030)
    |> YearSlug.maybe_generate_slug
    |> YearSlug.unique_constraint
  end
end
