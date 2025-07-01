defmodule McpNotes.Notes.Note do
  use Ash.Resource,
    domain: McpNotes.Notes,
    data_layer: AshSqlite.DataLayer

  sqlite do
    table "notes"
    repo McpNotes.Repo

    references do
      reference :project, on_delete: :delete, name: "notes_to_projects_fkey"
    end
  end

  code_interface do
    define :list_notes
    define :update_note
    define :add_note_to_project
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

      change manage_relationship(:project_id, :project, type: :append) do
        only_when_valid? true
      end
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

      change fn changeset, _ ->
        project_name = Ash.Changeset.get_argument(changeset, :project_name)
        content = Ash.Changeset.get_argument(changeset, :content)

        case McpNotes.Notes.Project.by_name(project_name) do
          {:ok, project} ->
            changeset
            |> Ash.Changeset.force_change_attribute(:content, content)
            |> Ash.Changeset.force_change_attribute(:project_id, project.id)

          {:error, _} ->
            Ash.Changeset.add_error(changeset, field: :project_name, message: "Project not found")
        end
      end
    end

    action :update_note do
      description "Update content of a specific note by ID"

      argument :note_id, :uuid_v7 do
        description "ID of the note to update"
        allow_nil? false
      end

      argument :content, :string do
        description "New content for the note"
        allow_nil? false
      end

      run fn input, _ ->
        note_id = Map.get(input.arguments, :note_id)
        content = Map.get(input.arguments, :content)

        case Ash.get(__MODULE__, note_id) do
          {:ok, note} ->
            case Ash.update(note, %{content: content}) do
              {:ok, _updated_note} ->
                :ok

              {:error, error} ->
                {:error, "Failed to update note: #{inspect(error)}"}
            end

          {:error, _} ->
            {:error, "Note not found: #{note_id}"}
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
