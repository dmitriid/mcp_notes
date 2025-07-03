defmodule McpNotes.Notes do
  @moduledoc """
  The Notes context. Manages projects and notes with AI tool integration.
  
  Provides tools for listing, creating, updating, and deleting projects and notes,
  as well as retrieving statistics about the stored data.
  """
  
  use Ash.Domain, extensions: [AshAi]

  alias McpNotes.Notes.{Project, Note}

  tools do
    tool :list_projects, Project, :list_projects
    tool :list_notes, Note, :list_notes
    tool :list_notes_for_project, Note, :list_notes_for_project
    tool :add_project, Project, :add_project
    tool :add_note_to_project, Note, :add_note_to_project
    tool :update_note, Note, :update_note
    tool :delete_note, Note, :delete_note
    tool :delete_project, Project, :delete_project
    tool :delete_notes_for_project, Project, :delete_notes_for_project
    tool :stats, Project, :stats
  end

  resources do
    resource Project
    resource Note
    resource McpNotes.Accounts.User
  end
end
