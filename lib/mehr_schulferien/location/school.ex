defmodule MehrSchulferien.Location.School do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Location.School
  alias MehrSchulferien.Location.SchoolSlug
  import Ecto.Query

  schema "schools" do
    field :address_city, :string
    field :address_line1, :string
    field :address_line2, :string
    field :address_street, :string
    field :address_zip_code, :string
    field :email_address, :string
    field :fax_number, :string
    field :homepage_url, :string
    field :name, :string
    field :phone_number, :string
    field :slug, :string
    field :city_id, :id
    field :federal_state_id, :id
    field :country_id, :id

    timestamps()
  end

  @doc false
  def changeset(%School{} = school, attrs) do
    school
    |> cast(attrs, [:name, :slug, :address_line1, :address_line2, :address_street, :address_zip_code, :address_city, :email_address, :phone_number, :fax_number, :homepage_url, :country_id, :federal_state_id, :city_id])
    |> validate_required([:name, :country_id, :federal_state_id, :city_id])
    |> set_address_zip_code
    |> set_slug
    |> unique_constraint(:slug)
  end

  defp set_address_zip_code(changeset) do
    address_zip_code = get_field(changeset, :address_zip_code)
    city_id = get_field(changeset, :city_id)

    case address_zip_code do
      nil -> query = from c in MehrSchulferien.Location.City, where: c.id == ^city_id
             city = MehrSchulferien.Repo.one(query)
             put_change(changeset, :address_zip_code, city.zip_code)
      _ -> changeset
    end
  end

  defp set_slug(changeset) do
    slug = get_field(changeset, :slug)

    case slug do
      nil -> changeset
             |> SchoolSlug.maybe_generate_slug
             |> SchoolSlug.unique_constraint
      _ -> changeset
    end
  end
end
