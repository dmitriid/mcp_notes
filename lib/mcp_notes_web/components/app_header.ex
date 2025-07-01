defmodule McpNotesWeb.Components.AppHeader do
  use McpNotesWeb, :html
  alias McpNotesWeb.Components.{Icon, Navigation}

  @doc """
  Renders the main application header.
  
  ## Examples
  
      <.header 
        projects={@projects} 
        selected_project={@selected_project}
        sidebar_open={@sidebar_open}
        show_back_button={true} 
      />
  """
  def header(assigns) do
    assigns = assign_new(assigns, :show_back_button, fn -> false end)
    
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8 py-4 sm:py-6 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-2 sm:space-x-4">
          <Navigation.mobile_nav projects={@projects} selected_project={@selected_project} sidebar_open={@sidebar_open} />
          
          <%= if @show_back_button do %>
            <.link
              navigate={~p"/"}
              class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-200 rounded-md px-2 py-1"
            >
              <Icon.icon name="hero-chevron-left" class="w-4 h-4 mr-1" />
              <span class="hidden sm:inline">Back to Home</span>
              <span class="sm:hidden">Back</span>
            </.link>
          <% else %>
            <h1 class="text-xl sm:text-2xl font-semibold text-gray-900">Notes</h1>
          <% end %>
        </div>

        <div class="flex items-center">
          <button 
            class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
            phx-click={if @selected_project, do: "show_add_note", else: "show_add_project"}
          >
            <Icon.icon name="hero-plus" class="w-4 h-4 sm:mr-2" />
            <span class="hidden sm:inline">New <%= if @selected_project, do: "Note", else: "Project" %></span>
          </button>
        </div>
      </div>
    </div>
    """
  end
end