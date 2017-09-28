defmodule MehrSchulferien.Calendar.Day do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Calendar.Day
  alias MehrSchulferien.Calendar.DaySlug


  schema "days" do
    field :slug, :string
    field :value, :integer
    field :date_value, :date
    field :weekday, :integer
    field :weekday_de, :string
    field :day_of_year, :integer
    belongs_to :year, MehrSchulferien.Calendar.Year
    belongs_to :month, MehrSchulferien.Calendar.Month
    has_many :slots, MehrSchulferien.Calendar.Slot
    has_many :periods, through: [:slots, :period]


    timestamps()
  end

  @doc false
  def changeset(%Day{} = day, attrs) do
    day
    |> cast(attrs, [:value, :year_id, :month_id, :date_value])
    |> validate_required([:value, :year_id, :month_id])
    |> validate_inclusion(:value, 1..31)
    |> assoc_constraint(:year)
    |> assoc_constraint(:month)
    |> DaySlug.maybe_generate_slug
    |> DaySlug.unique_constraint
    |> unique_constraint(:slug)
    |> set_weekday
    |> set_date_value
    |> validate_inclusion(:weekday, 1..7)
    |> set_weekday_de
    |> validate_inclusion(:weekday_de, ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"])
    |> set_day_of_year
    |> validate_inclusion(:day_of_year, 1..366)
  end

  defp set_date_value(changeset) do
    [year, month, day] = year_month_day(changeset)
    date_value = get_field(changeset, :date_value)

    case date_value do
      nil ->
        date = Date.from_erl!({year, month, day})
        put_change(changeset, :date_value, date)
      _ -> changeset
    end
  end

  defp set_weekday(changeset) do
    [year, month, day] = year_month_day(changeset)
    weekday = Date.day_of_week(Date.from_erl!({year, month, day}))

    put_change(changeset, :weekday, weekday)
  end

  defp set_weekday_de(changeset) do
    weekday = get_field(changeset, :weekday)

    weekday_de = case weekday do
      1 -> "Montag"
      2 -> "Dienstag"
      3 -> "Mittwoch"
      4 -> "Donnerstag"
      5 -> "Freitag"
      6 -> "Samstag"
      7 -> "Sonntag"
      _ -> nil
    end

    put_change(changeset, :weekday_de, weekday_de)
  end

  defp set_day_of_year(changeset) do
    [year, month, day] = year_month_day(changeset)
    first_day_of_the_year = Date.from_erl!({year, 1, 1})
    date = Date.from_erl!({year, month, day})
    day_of_year = Date.diff(date, first_day_of_the_year) + 1

    put_change(changeset, :day_of_year, day_of_year)
  end

  defp year_month_day(changeset) do
    slug = get_field(changeset, :slug)

    case slug do
      nil -> [nil, nil, nil]
      _ -> case String.split(slug, "-") do
            [year, month, day] -> [String.to_integer(year), String.to_integer(month), String.to_integer(day)]
           end
    end
  end
end
