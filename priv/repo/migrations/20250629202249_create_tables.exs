defmodule McpNotes.Repo.Migrations.CreateTables do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_sqlite.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:projects, primary_key: false) do
      # add :archived_at, :utc_datetime_usec
      add :updated_at, :utc_datetime_usec, null: false
      add :inserted_at, :utc_datetime_usec, null: false
      add :name, :text, null: false
      add :id, :uuid, null: false, primary_key: true
    end

    create unique_index(:projects, [:name], name: "projects_unique_name_index")

    create table(:notes, primary_key: false) do
      # add :archived_at, :utc_datetime_usec

      # add :project_id,
      #     references(:projects, column: :id, name: "notes_project_id_fkey", type: :uuid),
      #     null: false

      add :project_id,
          references(:projects,
            column: :id,
            name: "notes_to_projects_fkey",
            type: :uuid,
            on_delete: :delete_all
          )

      add :updated_at, :utc_datetime_usec, null: false
      add :inserted_at, :utc_datetime_usec, null: false
      add :content, :text, null: false
      add :id, :uuid, null: false, primary_key: true
    end
  end

  def down do
    # drop constraint(:notes, "notes_project_id_fkey")

    drop table(:notes)

    drop_if_exists unique_index(:projects, [:name], name: "projects_unique_name_index")

    drop table(:projects)
  end
end
