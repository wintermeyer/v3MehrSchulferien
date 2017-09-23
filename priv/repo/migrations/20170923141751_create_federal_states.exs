defmodule MehrSchulferien.Repo.Migrations.CreateFederalStates do
  use Ecto.Migration

  def change do
    create table(:federal_states) do
      add :name, :string
      add :slug, :string
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:federal_states, [:slug])
    create index(:federal_states, [:country_id])
  end
end
