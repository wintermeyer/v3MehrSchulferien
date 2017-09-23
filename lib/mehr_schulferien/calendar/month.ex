defmodule MehrSchulferien.Calendar.Month do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Calendar.Month
  alias MehrSchulferien.Calendar.MonthSlug


  schema "months" do
    field :value, :integer
    field :slug, MonthSlug.Type
    belongs_to :year, MehrSchulferien.Calendar.Year

    timestamps()
  end

  @doc false
  def changeset(%Month{} = month, attrs) do
    month
    |> cast(attrs, [:value, :year_id])
    |> validate_required([:value, :year_id])
    |> unique_constraint(:slug)
    |> assoc_constraint(:year)
    |> validate_inclusion(:value, 1..12)
    |> MonthSlug.maybe_generate_slug
    |> MonthSlug.unique_constraint
  end
end
