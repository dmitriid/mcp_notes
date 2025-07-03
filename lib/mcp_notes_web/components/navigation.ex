defmodule McpNotesWeb.Components.Navigation do
  @moduledoc """
  Navigation components for the application.
  
  Includes the main navigation sidebar and mobile navigation overlay.
  Displays recent projects and provides navigation between different views.
  """
  
  use McpNotesWeb, :html
  alias McpNotesWeb.Components.Icon

  @doc """
  Renders the main navigation sidebar component.
  
  ## Examples
  
      <.sidebar projects={@projects} selected_project={@selected_project} />
  """
  def nav_sidebar(assigns) do
    ~H"""
    <div class="space-y-2">
      <div class="text-xs font-medium text-gray-600 uppercase tracking-wider mb-4">Navigation</div>
      
      <.link
        navigate={~p"/"}
        class={[
          "w-full flex items-center px-3 py-2 text-sm font-medium rounded-md text-gray-700",
          if(is_nil(@selected_project), do: "bg-gray-200", else: "hover:bg-gray-200")
        ]}
      >
        <Icon.icon name="hero-folder-open" class="w-4 h-4 mr-3" />
        All Projects
      </.link>
      
      <div class="pt-4">
        <div class="text-xs font-medium text-gray-600 uppercase tracking-wider mb-3">Recent Projects</div>
        <%= for project <- Enum.take(@projects, 3) do %>
          <.link
            navigate={~p"/projects/#{project.id}"}
            class={[
              "w-full flex items-center px-3 py-2 mb-1 text-sm font-medium rounded-md text-gray-700",
              if(@selected_project && @selected_project.id == project.id, 
                do: "bg-gray-200", 
                else: "hover:bg-gray-200")
            ]}
          >
            <Icon.icon name={get_project_icon(project)} class="w-4 h-4 mr-3 text-purple-600 flex-shrink-0" />
            <div class="flex-1 min-w-0 text-left">
              <div class="truncate font-medium"><%= project.name %></div>
              <div class="text-xs text-gray-500"><%= length(project.notes) %> notes</div>
            </div>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders the mobile navigation sheet component.
  
  ## Examples
  
      <.mobile_nav projects={@projects} selected_project={@selected_project} sidebar_open={@sidebar_open} />
  """
  def mobile_nav(assigns) do
    ~H"""
    <!-- Mobile menu button -->
    <button 
      phx-click="toggle_sidebar"
      class="lg:hidden -ml-2 inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100"
    >
      <Icon.icon name="hero-bars-3" class="w-5 h-5" />
    </button>

    <!-- Mobile sidebar overlay -->
    <%= if @sidebar_open do %>
      <div class="lg:hidden fixed inset-0 z-40 flex">
        <!-- Overlay background -->
        <div 
          class="fixed inset-0 bg-gray-600 bg-opacity-75"
          phx-click="toggle_sidebar"
        ></div>
        
        <!-- Sidebar panel -->
        <div class="relative flex flex-col flex-1 w-64 max-w-xs bg-white" style="background-color: #f8f8fa;">
          <div class="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
            <div class="px-6">
              <.nav_sidebar projects={@projects} selected_project={@selected_project} />
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def get_project_icon(project) do
    case length(project.notes) do
      0 -> "hero-document"
      _ -> "hero-document-duplicate"
    end
  end
end