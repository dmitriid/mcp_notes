defmodule McpNotesWeb.ProjectDetailLive do
  use McpNotesWeb, :live_view
  import Phoenix.HTML
  alias McpNotes.Notes.Project
  alias McpNotesWeb.Components.{Icon, Navigation, AppHeader}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Ash.get(Project, id, load: [:notes, :last_note_updated_at]) do
      {:ok, project} ->
        if connected?(socket) do
          # Subscribe to this specific project's updates
          Phoenix.PubSub.subscribe(McpNotes.PubSub, "project:updated:#{id}")
          Phoenix.PubSub.subscribe(McpNotes.PubSub, "project:destroyed:#{id}")

          # Subscribe to notes for this project
          Phoenix.PubSub.subscribe(McpNotes.PubSub, "note:created:#{id}")
          Phoenix.PubSub.subscribe(McpNotes.PubSub, "note:updated:#{id}")
          Phoenix.PubSub.subscribe(McpNotes.PubSub, "note:destroyed:#{id}")
          Phoenix.PubSub.subscribe(McpNotes.PubSub, "project:notes_deleted:#{id}")
        end

        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()

        socket =
          socket
          |> assign(:project, project)
          |> assign(:projects, projects)
          |> assign(:recent_projects, recent_projects)
          |> assign(:selected_project, project)
          |> assign(:sidebar_open, false)
          |> assign(:expanded_note, nil)
          |> assign(:page_title, project.name)
          |> assign(:deleting_note, nil)
          |> assign(:editing_note, nil)
          |> assign(:edit_content, "")
          |> assign(:show_add_note, false)
          |> assign(:new_note_content, "")
          |> assign(:deleting_project, false)
          |> assign(:editing_project, false)
          |> assign(:edit_project_name, "")

        {:ok, socket}

      {:error, _} ->
        {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background-color: #f8f8fa;">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <AppHeader.header
          projects={@recent_projects}
          selected_project={@selected_project}
          sidebar_open={@sidebar_open}
          show_back_button={true}
        />

        <div class="flex">
          <!-- Desktop Sidebar -->
          <div class="hidden lg:block w-64 p-6">
            <Navigation.nav_sidebar projects={@recent_projects} selected_project={@selected_project} />
          </div>
          
    <!-- Main Content -->
          <div class="flex-1 p-4 sm:p-6 lg:p-8">
            <!-- Project Header Card -->
            <div class="mb-6 sm:mb-8">
              <div class="bg-white p-4 sm:p-6 border border-gray-200 rounded-lg">
                <div class="flex flex-col sm:flex-row sm:items-center space-y-4 sm:space-y-0 sm:space-x-4 mb-4">
                  <div class="w-12 h-12 sm:w-16 sm:h-16 bg-purple-100 rounded-2xl flex items-center justify-center flex-shrink-0">
                    <Icon.icon
                      name={Navigation.get_project_icon(@project)}
                      class="w-6 h-6 sm:w-8 sm:h-8 text-purple-600"
                    />
                  </div>
                  <div class="min-w-0 flex-1">
                    <%= if @editing_project do %>
                      <form phx-submit="save_project" class="space-y-3">
                        <input
                          type="text"
                          name="name"
                          class="text-2xl sm:text-3xl font-bold border-2 border-purple-300 rounded-md px-3 py-1 w-full focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                          value={@edit_project_name}
                          required
                        />
                        <div class="flex items-center space-x-2">
                          <button
                            type="submit"
                            class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 text-sm"
                          >
                            Update
                          </button>
                          <button
                            type="button"
                            class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 text-sm"
                            phx-click="cancel_edit_project"
                          >
                            Cancel
                          </button>
                        </div>
                      </form>
                    <% else %>
                      <div class="flex items-center justify-between relative">
                        <h2
                          class="text-2xl sm:text-3xl font-bold text-gray-900"
                          class={if @deleting_project, do: "truncate pr-32", else: "truncate"}
                        >
                          {@project.name}
                        </h2>
                        <div class="flex items-center space-x-1 absolute right-0">
                          <button
                            class="h-8 w-8 p-0 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-blue-600 hover:bg-gray-100"
                            phx-click="edit_project"
                          >
                            <Icon.icon name="hero-pencil" class="w-4 h-4" />
                          </button>
                          <%= if @deleting_project do %>
                            <div class="flex items-center space-x-1 bg-red-50 border border-red-200 rounded-md px-2 py-1 text-xs shadow-lg">
                              <span class="text-red-700">Delete?</span>
                              <button
                                class="px-2 py-1 bg-red-600 text-white rounded text-xs hover:bg-red-700"
                                phx-click="confirm_delete_project"
                              >
                                Delete
                              </button>
                              <button
                                class="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs hover:bg-gray-200"
                                phx-click="cancel_delete_project"
                              >
                                Cancel
                              </button>
                            </div>
                          <% else %>
                            <button
                              class="h-8 w-8 p-0 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-red-600 hover:bg-gray-100"
                              phx-click="delete_project"
                            >
                              <Icon.icon name="hero-trash" class="w-4 h-4" />
                            </button>
                          <% end %>
                        </div>
                      </div>
                      <p class="text-gray-600 text-base sm:text-lg mt-1">
                        {project_description(@project)}
                      </p>
                    <% end %>
                  </div>
                </div>

                <div class="flex flex-col sm:flex-row sm:items-center sm:space-x-6 text-sm text-gray-500 space-y-2 sm:space-y-0">
                  <div class="flex items-center space-x-2">
                    <Icon.icon name="hero-document-text" class="w-4 h-4" />
                    <span>{length(@project.notes)} notes</span>
                  </div>
                  <div class="flex items-center space-x-2">
                    <Icon.icon name="hero-calendar" class="w-4 h-4" />
                    <span>
                      Last updated {format_date(@project.last_note_updated_at || @project.updated_at)}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            
    <!-- Add Note Form -->
            <%= if @show_add_note do %>
              <div class="mb-6 bg-white border border-gray-200 rounded-lg p-4 sm:p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">Add New Note</h3>
                <form phx-submit="add_note" class="space-y-4">
                  <textarea
                    name="content"
                    class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-purple-500 focus:border-purple-500 resize-vertical"
                    rows="6"
                    placeholder="Enter your note content..."
                    value={@new_note_content}
                  ></textarea>
                  <div class="flex items-center space-x-2">
                    <button
                      type="submit"
                      class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700"
                    >
                      Add Note
                    </button>
                    <button
                      type="button"
                      class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200"
                      phx-click="cancel_add_note"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            <% end %>
            
    <!-- Notes List -->
            <div class="space-y-4">
              <%= for note <- Enum.sort_by(@project.notes, & &1.inserted_at, {:desc, DateTime}) do %>
                <div class="border border-gray-200 hover:shadow-md transition-all duration-200 hover:border-purple-200 bg-white group rounded-lg">
                  <div
                    class="cursor-pointer p-4 sm:p-6"
                    phx-click="toggle_note"
                    phx-value-id={note.id}
                  >
                    <div class="flex items-start justify-between">
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center justify-between relative mb-1">
                          <h3
                            class="text-lg sm:text-xl text-gray-900 font-semibold"
                            class={
                              if @deleting_note == note.id, do: "truncate pr-32", else: "truncate"
                            }
                          >
                            {note_title(note)}
                          </h3>
                          <div class="flex items-center space-x-1 absolute right-0">
                            <button
                              class="h-8 w-8 p-0 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-blue-600 hover:bg-gray-100"
                              phx-click="edit_note"
                              phx-value-id={note.id}
                            >
                              <Icon.icon name="hero-pencil" class="w-4 h-4" />
                            </button>
                            <%= if @deleting_note == note.id do %>
                              <div class="flex items-center space-x-1 bg-red-50 border border-red-200 rounded-md px-2 py-1 text-xs shadow-lg">
                                <span class="text-red-700">Delete?</span>
                                <button
                                  class="px-2 py-1 bg-red-600 text-white rounded text-xs hover:bg-red-700"
                                  phx-click="confirm_delete_note"
                                  phx-value-id={note.id}
                                >
                                  Delete
                                </button>
                                <button
                                  class="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs hover:bg-gray-200"
                                  phx-click="cancel_delete_note"
                                >
                                  Cancel
                                </button>
                              </div>
                            <% else %>
                              <button
                                class="h-8 w-8 p-0 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-red-600 hover:bg-gray-100"
                                phx-click="delete_note"
                                phx-value-id={note.id}
                              >
                                <Icon.icon name="hero-trash" class="w-4 h-4" />
                              </button>
                            <% end %>
                          </div>
                        </div>

                        <div class="text-sm text-gray-500 mb-3">
                          {format_date(note.inserted_at)}
                        </div>

                        <div class="text-gray-600 leading-relaxed text-sm sm:text-base">
                          <%= if @editing_note == note.id do %>
                            <div class="pt-4 border-t border-gray-100 mt-4">
                              <form phx-submit="save_note" class="space-y-3">
                                <input type="hidden" name="note_id" value={note.id} />
                                <textarea
                                  name="content"
                                  class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-purple-500 focus:border-purple-500 resize-vertical"
                                  rows="6"
                                  placeholder="Enter your note content..."
                                ><%= @edit_content %></textarea>
                                <div class="flex items-center space-x-2">
                                  <button
                                    type="submit"
                                    class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 text-sm"
                                  >
                                    Update
                                  </button>
                                  <button
                                    type="button"
                                    class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 text-sm"
                                    phx-click="cancel_edit_note"
                                  >
                                    Cancel
                                  </button>
                                </div>
                              </form>
                            </div>
                          <% else %>
                            <%= if @expanded_note == note.id do %>
                              <div class="pt-4 text-gray-800 border-t border-gray-100 mt-4 expanded-note-content">
                                {render_markdown_content(note.content)}
                              </div>
                            <% else %>
                              {note_preview(note)}
                            <% end %>
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, assign(socket, :sidebar_open, !socket.assigns.sidebar_open)}
  end

  @impl true
  def handle_event("toggle_note", %{"id" => id}, socket) do
    expanded_note = if socket.assigns.expanded_note == id, do: nil, else: id
    {:noreply, assign(socket, :expanded_note, expanded_note)}
  end

  @impl true
  def handle_event("edit_note", %{"id" => id}, socket) do
    note = Enum.find(socket.assigns.project.notes, &(&1.id == id))
    {:noreply, assign(socket, editing_note: id, edit_content: note.content, expanded_note: id)}
  end

  @impl true
  def handle_event("cancel_edit_note", _, socket) do
    {:noreply, assign(socket, editing_note: nil, edit_content: "")}
  end

  @impl true
  def handle_event("save_note", %{"note_id" => id, "content" => content}, socket) do
    case McpNotes.Notes.Note.update_note(%{note_id: id, content: content}) do
      {:ok, _} ->
        {:ok, project} =
          Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

        {:ok, recent_projects} = Project.list_recent_projects()

        {:noreply,
         assign(socket,
           project: project,
           recent_projects: recent_projects,
           editing_note: nil,
           edit_content: ""
         )}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update note")}
    end
  end

  @impl true
  def handle_event("delete_note", %{"id" => id}, socket) do
    {:noreply, assign(socket, :deleting_note, id)}
  end

  @impl true
  def handle_event("cancel_delete_note", _, socket) do
    {:noreply, assign(socket, :deleting_note, nil)}
  end

  @impl true
  def handle_event("confirm_delete_note", %{"id" => id}, socket) do
    note = Enum.find(socket.assigns.project.notes, &(&1.id == id))

    case Ash.destroy(note) do
      :ok ->
        {:ok, project} =
          Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

        {:ok, recent_projects} = Project.list_recent_projects()

        {:noreply,
         assign(socket, project: project, recent_projects: recent_projects, deleting_note: nil)}

      {:ok, _} ->
        {:ok, project} =
          Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

        {:ok, recent_projects} = Project.list_recent_projects()

        {:noreply,
         assign(socket, project: project, recent_projects: recent_projects, deleting_note: nil)}

      {:error, _} ->
        {:noreply,
         put_flash(socket, :error, "Failed to delete note") |> assign(:deleting_note, nil)}
    end
  end

  @impl true
  def handle_event("show_add_note", _, socket) do
    {:noreply, assign(socket, show_add_note: true, new_note_content: "")}
  end

  @impl true
  def handle_event("cancel_add_note", _, socket) do
    {:noreply, assign(socket, show_add_note: false, new_note_content: "")}
  end

  @impl true
  def handle_event("add_note", %{"content" => content}, socket) do
    case McpNotes.Notes.Note.add_note_to_project(%{
           project_name: socket.assigns.project.name,
           content: content
         }) do
      {:ok, _} ->
        {:ok, project} =
          Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

        {:ok, recent_projects} = Project.list_recent_projects()

        {:noreply,
         assign(socket,
           project: project,
           recent_projects: recent_projects,
           show_add_note: false,
           new_note_content: ""
         )}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to add note")}
    end
  end

  @impl true
  def handle_event("edit_project", _, socket) do
    {:noreply,
     assign(socket, editing_project: true, edit_project_name: socket.assigns.project.name)}
  end

  @impl true
  def handle_event("cancel_edit_project", _, socket) do
    {:noreply, assign(socket, editing_project: false, edit_project_name: "")}
  end

  @impl true
  def handle_event("save_project", %{"name" => name}, socket) do
    case Ash.update(socket.assigns.project, %{name: name}) do
      {:ok, project} ->
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()

        {:noreply,
         assign(socket,
           project: project,
           projects: projects,
           recent_projects: recent_projects,
           editing_project: false,
           edit_project_name: ""
         )}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update project")}
    end
  end

  @impl true
  def handle_event("delete_project", _, socket) do
    {:noreply, assign(socket, :deleting_project, true)}
  end

  @impl true
  def handle_event("cancel_delete_project", _, socket) do
    {:noreply, assign(socket, :deleting_project, false)}
  end

  @impl true
  def handle_event("confirm_delete_project", _, socket) do
    case Ash.destroy(socket.assigns.project) do
      :ok ->
        {:noreply, push_navigate(socket, to: ~p"/")}

      {:ok, _} ->
        {:noreply, push_navigate(socket, to: ~p"/")}

      {:error, _} ->
        {:noreply,
         put_flash(socket, :error, "Failed to delete project") |> assign(:deleting_project, false)}
    end
  end

  # PubSub notification handlers
  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %Ash.Notifier.Notification{resource: Project, action: action, data: _data}
        },
        socket
      ) do
    case action.name do
      :update ->
        # Project was updated, reload it
        {:ok, project} =
          Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, project: project, recent_projects: recent_projects)}

      action_name when action_name in [:destroy, :delete_project] ->
        # Project was deleted, redirect to home
        {:noreply, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %Ash.Notifier.Notification{
            resource: McpNotes.Notes.Note,
            action: action,
            data: _data
          }
        },
        socket
      ) do
    case action.name do
      action_name when action_name in [:create, :update, :destroy, :add_note_to_project, :update_note] ->
        # Note changed, reload project with notes
        {:ok, project} =
          Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, project: project, recent_projects: recent_projects)}
    end
  end

  @impl true
  def handle_info({:notes_deleted, _project}, socket) do
    # Notes deleted via MCP, reload project with notes
    {:ok, project} =
      Ash.get(Project, socket.assigns.project.id, load: [:notes, :last_note_updated_at])

    {:ok, recent_projects} = Project.list_recent_projects()
    {:noreply, assign(socket, project: project, recent_projects: recent_projects)}
  end

  defp format_date(datetime) do
    case Timex.Format.DateTime.Formatters.Relative.format(datetime, "{relative}") do
      {:ok, formatted} -> formatted
      {:error, _} -> "unknown"
    end
  end

  defp project_description(project) do
    note_count = length(project.notes)

    if note_count == 0 do
      "No notes yet"
    else
      "Project workspace"
    end
  end

  defp note_title(note) do
    # Extract title from first line or generate from content
    first_line = note.content |> String.split("\n") |> List.first() || ""

    cond do
      String.starts_with?(first_line, "#") ->
        String.replace(first_line, ~r/^#+\s*/, "")

      String.length(first_line) > 50 ->
        String.slice(first_line, 0, 50) <> "..."

      String.trim(first_line) == "" ->
        "Untitled Note"

      true ->
        first_line
    end
  end

  defp note_preview(note) do
    # Generate preview from content, skipping markdown headers
    lines = String.split(note.content, "\n")

    preview_lines =
      lines
      |> Enum.reject(fn line ->
        String.starts_with?(line, "#") || String.trim(line) == ""
      end)
      |> Enum.take(3)
      |> Enum.join(" ")

    if String.length(preview_lines) > 200 do
      String.slice(preview_lines, 0, 200) <> "..."
    else
      preview_lines
    end
  end

  defp render_markdown_content(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, html_doc, []} ->
        raw(html_doc)

      {:ok, html_doc, _deprecation_messages} ->
        raw(html_doc)

      {:error, _html_doc, _error_messages} ->
        assigns = %{markdown: markdown}
        ~H"""
        <div class="whitespace-pre-wrap">{@markdown}</div>
        """
    end
  end
end
