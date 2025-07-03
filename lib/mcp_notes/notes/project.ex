defmodule McpNotes.Notes.Project do
  @moduledoc """
  Resource representing projects that contain notes.
  
  Projects are the top-level organizational unit for notes. They support
  various queries including alphabetical sorting and sorting by recent activity.
  Includes actions for project and note management with real-time PubSub notifications.
  """
  
  use Ash.Resource,
    domain: McpNotes.Notes,
    data_layer: AshSqlite.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  import Ash.Expr

  sqlite do
    table "projects"
    repo McpNotes.Repo
  end

  code_interface do
    define :by_name, args: [:name]
    define :list_projects
    define :list_full_projects
    define :list_recent_projects
    define :add_project
    define :delete_project
    define :delete_notes_for_project
  end

  actions do
    defaults [:read]

    read :list_projects do
      description "Return all projects, sorted alphabetically"
      prepare build(sort: [:name])
    end

    read :list_full_projects do
      description "Return all projects, sorted alphabetically, with notes"
      prepare build(sort: [:name])
      prepare build(load: [:notes, :last_note_updated_at])
    end

    read :list_recent_projects do
      description "Return projects sorted by most recent note activity"
      prepare build(load: [:last_note_updated_at, :notes])
      prepare build(sort: [last_note_updated_at: :desc])
    end

    read :by_name do
      get_by :name
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
      description "Add new project with specified name"
      accept [:name]
    end

    action :delete_project, :map do
      description "Remove project and all its notes"

      argument :project_name, :string do
        description "Name of the project to delete"
        allow_nil? false
      end

      run fn input, _ ->
        project_name = Map.get(input.arguments, :project_name)

        case __MODULE__.by_name(project_name) do
          {:ok, project} ->
            case Ash.destroy(project) do
              :ok ->
                {:ok, %{message: "Deleted project '#{project_name}'"}}

              {:ok, _} ->
                {:ok, %{message: "Deleted project '#{project_name}'"}}

              {:error, error} ->
                {:error, "Failed to delete project: #{inspect(error)}"}
            end

          {:error, _} ->
            {:error, "Project not found: #{project_name}"}
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

        case __MODULE__.by_name(project_name) do
          {:ok, project} ->
            result =
              Ash.bulk_destroy(McpNotes.Notes.Note, :destroy, %{},
                filter: expr(project_id == ^project.id)
              )

            case result.status do
              :success ->
                # Manually broadcast pubsub event for LiveView updates
                Phoenix.PubSub.broadcast(
                  McpNotes.PubSub,
                  "project:notes_deleted:#{project.id}",
                  {:notes_deleted, project}
                )
                
                Phoenix.PubSub.broadcast(
                  McpNotes.PubSub,
                  "projects:all",
                  {:notes_deleted, project}
                )

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
        case __MODULE__.list_full_projects() do
          {:ok, projects} ->
            project_stats = %{
              total_projects: length(projects),
              total_notes:
                Enum.reduce(projects, 0, fn project, acc -> acc + length(project.notes) end),
              projects:
                projects
                |> Enum.map(fn project ->
                  %{
                    name: project.name,
                    note_count: length(project.notes)
                  }
                end)
                |> Enum.sort_by(& &1.name)
            }

            {:ok, project_stats}
          
          {:error, error} ->
            {:error, Exception.message(error)}
        end
      end
    end
  end

  pub_sub do
    module McpNotesWeb.Endpoint
    prefix "project"

    publish :create, ["created", :id]
    publish :update, ["updated", :id]
    publish :destroy, ["destroyed", :id]

    publish :add_project, ["created", :id]

    publish :create, "projects:all"
    publish :update, "projects:all"
    publish :destroy, "projects:all"
    publish :add_project, "projects:all"
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

  relationships do
    has_many :notes, McpNotes.Notes.Note do
      destination_attribute :project_id
    end
  end

  calculations do
    calculate :last_note_updated_at,
              :utc_datetime,
              expr(fragment("SELECT MAX(updated_at) FROM notes WHERE project_id = ?", id)) do
      public? true
    end
  end

  identities do
    identity :unique_name, [:name]
  end
end
