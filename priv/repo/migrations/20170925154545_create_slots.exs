defmodule MehrSchulferien.Repo.Migrations.CreateSlots do
  use Ecto.Migration

  def change do
    create table(:slots) do
      add :period_id, references(:periods, on_delete: :nothing)
      add :day_id, references(:days, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:slots, [:period_id, :day_id], name: :slots_period_id_day_id_index)
    create index(:slots, [:period_id])
    create index(:slots, [:day_id])
  end
end
