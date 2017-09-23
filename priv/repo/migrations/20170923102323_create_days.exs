defmodule MehrSchulferien.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def change do
    create table(:days) do
      add :value, :integer
      add :slug, :string
      add :day_of_year, :integer
      add :weekday, :integer
      add :weekday_de, :string
      add :year_id, references(:years, on_delete: :nothing)
      add :month_id, references(:months, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:days, [:slug])
    create index(:days, [:year_id])
    create index(:days, [:month_id])
  end
end