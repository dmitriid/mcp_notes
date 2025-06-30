defmodule McpNotes.Notes.Note do
  use Ash.Resource,
    domain: McpNotes.Notes,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshArchival.Resource]

  sqlite do
    table "notes"
    repo McpNotes.Repo
  end

  actions do
    defaults [:read]

    read :list_notes do
      description "Returns all notes for all projects, sorted by creation time, descending"
      prepare build(sort: [inserted_at: :desc])
      prepare build(load: [:project])
    end

    read :list_notes_for_project do
      description "Returns notes for specified project, sorted by creation time, descending"

      argument :project_name, :string do
        description "Name of the project to get notes for"
        allow_nil? false
      end

      prepare build(sort: [inserted_at: :desc])
      filter expr(project.name == ^arg(:project_name))
    end

    create :create do
      primary? true
      accept [:content]

      argument :project_id, :uuid_v7 do
        allow_nil? false
      end

      change manage_relationship(:project_id, :project, type: :append)
    end

    update :update do
      primary? true
      accept [:content]
    end

    destroy :destroy do
      primary? true
    end

    create :add_note_to_project do
      description "Add new note to specified project name"

      argument :project_name, :string do
        description "Name of the project to add note to"
        allow_nil? false
      end

      argument :content, :string do
        description "Content of the note"
        allow_nil? false
      end

      change fn changeset, context ->
        IO.inspect({changeset, context})

        case Ash.get(McpNotes.Notes.Project, name: changeset.arguments.project_name) do
          {:ok, project} ->
            changeset
            |> Ash.Changeset.force_change_attribute(:content, changeset.arguments.content)
            |> Ash.Changeset.force_change_attribute(:project_id, project.id)

          {:error, _} ->
            Ash.Changeset.add_error(changeset, field: :project_name, message: "Project not found")
        end
      end
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :content, :string do
      allow_nil? false
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :project, McpNotes.Notes.Project do
      allow_nil? false
      attribute_writable? true
    end
  end
end
