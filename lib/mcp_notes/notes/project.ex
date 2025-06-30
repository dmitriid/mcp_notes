defmodule McpNotes.Notes.Project do
  use Ash.Resource,
    domain: McpNotes.Notes,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshArchival.Resource]

  import Ash.Expr

  sqlite do
    table "projects"
    repo McpNotes.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]

    read :list_projects do
      description "Return all projects, sorted alphabetically"
      prepare build(sort: [:name])
    end

    create :create do
      primary? true
      accept [:name]
    end

    update :update do
      primary? true
      accept [:name]
    end

    destroy :destroy do
      primary? true
      require_atomic? false
    end

    create :add_project do
      description "Add new project with specified name. If name already exists, adds (sequence number) to project name"
      
      argument :name, :string do
        description "Name of the project to create"
        allow_nil? false
      end

      change fn changeset, _ ->
        name = Ash.Changeset.get_argument(changeset, :name)
        unique_name = ensure_unique_project_name(name)
        Ash.Changeset.force_change_attribute(changeset, :name, unique_name)
      end
    end

    destroy :delete_project do
      description "Remove project and all its notes"
      require_atomic? false
      
      argument :project_name, :string do
        description "Name of the project to delete"
        allow_nil? false
      end

      change fn changeset, _ ->
        project_name = Ash.Changeset.get_argument(changeset, :project_name)
        case Ash.get(__MODULE__, name: project_name) do
          {:ok, project} ->
            Ash.Changeset.force_change_attribute(changeset, :id, project.id)
          {:error, _} ->
            Ash.Changeset.add_error(changeset, field: :project_name, message: "Project not found")
        end
      end
    end

    action :delete_notes_for_project, :map do
      description "Remove all notes for this project, but keep the project"
      
      argument :project_name, :string do
        description "Name of the project to delete notes from"
        allow_nil? false
      end

      run fn input, _ ->
        project_name = Map.get(input.arguments, :project_name)
        case Ash.get(__MODULE__, name: project_name) do
          {:ok, project} ->
            result = Ash.bulk_destroy(McpNotes.Notes.Note, :destroy, %{}, filter: expr(project_id == ^project.id))
            case result.status do
              :success ->
                {:ok, %{message: "Deleted notes from project '#{project_name}'"}}
              _ ->
                {:error, "Failed to delete notes"}
            end
          {:error, _} ->
            {:error, "Project not found: #{project_name}"}
        end
      end
    end

    action :stats, :map do
      description "Returns total number of projects, total number of notes, and a list of projects with number of notes per project"

      run fn _input, _ ->
        with {:ok, projects} <- Ash.read(__MODULE__),
             {:ok, notes} <- Ash.read(McpNotes.Notes.Note) do
          
          notes_by_project = 
            notes
            |> Enum.group_by(& &1.project_id)
            |> Enum.map(fn {project_id, project_notes} -> {project_id, length(project_notes)} end)
            |> Map.new()
          
          project_stats = 
            projects
            |> Enum.map(fn project ->
              %{
                name: project.name,
                note_count: Map.get(notes_by_project, project.id, 0)
              }
            end)
            |> Enum.sort_by(& &1.name)
          
          {:ok, %{
            total_projects: length(projects),
            total_notes: length(notes),
            projects: project_stats
          }}
        else
          {:error, error} ->
            {:error, Exception.message(error)}
        end
      end
    end
  end

  relationships do
    has_many :notes, McpNotes.Notes.Note do
      destination_attribute :project_id
    end
  end

  identities do
    identity :unique_name, [:name]
  end

  defp ensure_unique_project_name(name, counter \\ 0) do
    candidate_name = if counter == 0, do: name, else: "#{name} (#{counter})"
    
    case Ash.get(__MODULE__, name: candidate_name) do
      {:ok, _} -> ensure_unique_project_name(name, counter + 1)
      {:error, _} -> candidate_name
    end
  end
end