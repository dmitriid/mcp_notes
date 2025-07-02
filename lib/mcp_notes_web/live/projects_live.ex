defmodule McpNotesWeb.ProjectsLive do
  use McpNotesWeb, :live_view
  alias McpNotes.Notes.Project
  alias McpNotesWeb.Components.{Icon, Navigation, AppHeader}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to all project changes
      Phoenix.PubSub.subscribe(McpNotes.PubSub, "project:projects:all")
    end
    
    {:ok, projects} = Project.list_full_projects()
    {:ok, recent_projects} = Project.list_recent_projects()
    
    socket =
      socket
      |> assign(:projects, projects)
      |> assign(:recent_projects, recent_projects)
      |> assign(:selected_project, nil)
      |> assign(:sidebar_open, false)
      |> assign(:page_title, "Projects")
      |> assign(:deleting_project, nil)
      |> assign(:show_add_project, false)
      |> assign(:new_project_name, "")
      |> assign(:editing_project, nil)
      |> assign(:edit_project_name, "")
    
    {:ok, socket}
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
          show_back_button={false}
        />

        <div class="flex">
          <!-- Desktop Sidebar -->
          <div class="hidden lg:block w-64 p-6">
            <Navigation.nav_sidebar projects={@recent_projects} selected_project={@selected_project} />
          </div>
          

          <!-- Main Content -->
          <div class="flex-1 p-4 sm:p-6 lg:p-8">
            <div class="mb-6 sm:mb-8">
              <h2 class="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Your Projects</h2>
              <p class="text-gray-700 text-base sm:text-lg">
                Organize your notes and ideas by project for better focus and collaboration.
              </p>
            </div>

            <!-- Add Project Popup -->
            <%= if @show_add_project do %>
              <div class="mb-6">
                <div class="bg-white border border-purple-200 rounded-lg p-4 shadow-lg max-w-md">
                  <h3 class="text-lg font-semibold text-gray-900 mb-4">Add New Project</h3>
                  <form phx-submit="add_project" phx-change="update_project_name" class="space-y-4">
                    <input
                      type="text"
                      name="name"
                      class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                      placeholder="Project name"
                      value={@new_project_name}
                      required
                    />
                    <div class="flex items-center space-x-2">
                      <button
                        type="submit"
                        class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700"
                      >
                        Add
                      </button>
                      <button
                        type="button"
                        class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200"
                        phx-click="cancel_add_project"
                      >
                        Cancel
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            <% end %>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
              <%= for project <- @projects do %>
                <div 
                  class={if @editing_project == project.id, do: "border border-gray-200 group bg-white rounded-lg", else: "cursor-pointer hover:shadow-lg transition-all duration-200 border border-gray-200 hover:border-purple-200 group bg-white rounded-lg"}
                  phx-click={if @editing_project == project.id, do: nil, else: "select_project"}
                  phx-value-id={if @editing_project == project.id, do: nil, else: project.id}
                >
                  <div class="p-4 sm:p-6">
                    <div class="flex items-start justify-between">
                      <div class="flex items-center space-x-3 flex-1 min-w-0">
                        <div class="w-10 h-10 sm:w-12 sm:h-12 bg-purple-100 rounded-xl flex items-center justify-center group-hover:bg-purple-200 transition-colors flex-shrink-0">
                          <Icon.icon name={Navigation.get_project_icon(project)} class="w-5 h-5 sm:w-6 sm:h-6 text-purple-600" />
                        </div>
                        <div class="min-w-0 flex-1">
                          <%= if @editing_project == project.id do %>
                            <form phx-submit="save_project_name" class="space-y-3">
                              <input type="hidden" name="project_id" value={project.id} />
                              <input
                                type="text"
                                name="name"
                                class="text-lg sm:text-xl font-semibold border-2 border-purple-300 rounded-md px-2 py-1 w-full focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                                value={@edit_project_name}
                                required
                              />
                              <div class="flex items-center space-x-2">
                                <button
                                  type="submit"
                                  class="px-3 py-1 bg-purple-600 text-white rounded-md hover:bg-purple-700 text-sm"
                                >
                                  Update
                                </button>
                                <button
                                  type="button"
                                  class="px-3 py-1 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 text-sm"
                                  phx-click="cancel_edit_project"
                                >
                                  Cancel
                                </button>
                              </div>
                            </form>
                          <% else %>
                            <div class="flex items-center justify-between relative">
                              <h3 class="text-lg sm:text-xl text-gray-900 group-hover:text-purple-900 transition-colors font-semibold" class={if @deleting_project == project.id, do: "truncate pr-32", else: "truncate"}>
                                <%= project.name %>
                              </h3>
                              <div class="flex items-center space-x-1 absolute right-0">
                                <button
                                  class="h-8 w-8 p-0 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-blue-600 hover:bg-gray-100"
                                  phx-click="rename_project"
                                  phx-value-id={project.id}
                                >
                                  <Icon.icon name="hero-pencil" class="w-4 h-4" />
                                </button>
                                <%= if @deleting_project == project.id do %>
                                  <div class="flex items-center space-x-1 bg-red-50 border border-red-200 rounded-md px-2 py-1 text-xs shadow-lg">
                                    <span class="text-red-700">Delete?</span>
                                    <button
                                      class="px-2 py-1 bg-red-600 text-white rounded text-xs hover:bg-red-700"
                                      phx-click="confirm_delete_project"
                                      phx-value-id={project.id}
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
                                    phx-value-id={project.id}
                                  >
                                    <Icon.icon name="hero-trash" class="w-4 h-4" />
                                  </button>
                                <% end %>
                              </div>
                            </div>
                          <% end %>
                          <div class="flex flex-col sm:flex-row sm:items-center sm:space-x-4 mt-2 text-sm text-gray-500 space-y-1 sm:space-y-0">
                            <div class="flex items-center space-x-1">
                              <Icon.icon name="hero-document-text" class="w-4 h-4" />
                              <span><%= length(project.notes) %> notes</span>
                            </div>
                            <div class="flex items-center space-x-1">
                              <Icon.icon name="hero-calendar" class="w-4 h-4" />
                              <span><%= format_date(project.last_note_updated_at || project.updated_at) %></span>
                            </div>
                          </div>
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
  def handle_event("select_project", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/projects/#{id}")}
  end

  @impl true
  def handle_event("rename_project", %{"id" => id}, socket) do
    project = Enum.find(socket.assigns.projects, &(&1.id == id))
    {:noreply, assign(socket, editing_project: id, edit_project_name: project.name)}
  end

  @impl true
  def handle_event("cancel_edit_project", _, socket) do
    {:noreply, assign(socket, editing_project: nil, edit_project_name: "")}
  end

  @impl true
  def handle_event("save_project_name", %{"project_id" => id, "name" => name}, socket) do
    project = Enum.find(socket.assigns.projects, &(&1.id == id))
    
    case Ash.update(project, %{name: name}) do
      {:ok, _} ->
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects, editing_project: nil, edit_project_name: "")}
      
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update project")}
    end
  end

  @impl true
  def handle_event("show_add_project", _, socket) do
    {:noreply, assign(socket, show_add_project: true, new_project_name: "")}
  end

  @impl true
  def handle_event("update_project_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, new_project_name: name)}
  end

  @impl true
  def handle_event("cancel_add_project", _, socket) do
    {:noreply, assign(socket, show_add_project: false, new_project_name: "")}
  end

  @impl true
  def handle_event("add_project", %{"name" => name}, socket) do
    # First check if project with this name already exists
    case Project.by_name(name) do
      {:ok, existing_project} ->
        # Project already exists, redirect to it
        socket = assign(socket, show_add_project: false, new_project_name: "")
        {:noreply, push_navigate(socket, to: ~p"/projects/#{existing_project.id}")}
      
      {:error, _} ->
        # Project doesn't exist, create it
        case Project.add_project(%{name: name}) do
          {:ok, project} ->
            socket = assign(socket, show_add_project: false, new_project_name: "")
            {:noreply, push_navigate(socket, to: ~p"/projects/#{project.id}")}
          
          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to create project")}
        end
    end
  end

  @impl true
  def handle_event("delete_project", %{"id" => id}, socket) do
    {:noreply, assign(socket, :deleting_project, id)}
  end

  @impl true
  def handle_event("cancel_delete_project", _, socket) do
    {:noreply, assign(socket, :deleting_project, nil)}
  end

  @impl true
  def handle_event("confirm_delete_project", %{"id" => id}, socket) do
    project = Enum.find(socket.assigns.projects, &(&1.id == id))
    
    case Ash.destroy(project) do
      :ok ->
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects, deleting_project: nil)}
      
      {:ok, _} ->
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects, deleting_project: nil)}
      
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete project") |> assign(:deleting_project, nil)}
    end
  end

  # PubSub notification handlers
  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: _event, payload: %Ash.Notifier.Notification{action: action, data: data}}, socket) do
    case action.name do
      action_name when action_name in [:create, :add_project] ->
        # Reload projects list
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects)}
        
      :update ->
        # Update specific project in list
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects)}
        
      action_name when action_name in [:destroy, :delete_project] ->
        # Remove project from list
        projects = Enum.reject(socket.assigns.projects, &(&1.id == data.id))
        recent_projects = Enum.reject(socket.assigns.recent_projects, &(&1.id == data.id))
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects)}
        
      :delete_notes_for_project ->
        # Just reload to get updated last_note_updated_at
        {:ok, projects} = Project.list_full_projects()
        {:ok, recent_projects} = Project.list_recent_projects()
        {:noreply, assign(socket, projects: projects, recent_projects: recent_projects)}
    end
  end

  defp format_date(datetime) do
    case Timex.Format.DateTime.Formatters.Relative.format(datetime, "{relative}") do
      {:ok, formatted} -> formatted
      {:error, _} -> "unknown"
    end
  end

end