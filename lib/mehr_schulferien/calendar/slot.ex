defmodule MehrSchulferien.Calendar.Slot do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Calendar.Slot


  schema "slots" do
    belongs_to :period, MehrSchulferien.Calendar.Period
    belongs_to :day, MehrSchulferien.Calendar.Day

    timestamps()
  end

  @doc false
  def changeset(%Slot{} = slot, attrs) do
    slot
    |> cast(attrs, [:period_id, :day_id])
    |> validate_required([:period_id, :day_id])
    |> unique_constraint(:period_id, name: :slots_period_id_day_id_index)
  end
end
