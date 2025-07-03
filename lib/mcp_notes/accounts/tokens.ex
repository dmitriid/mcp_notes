defmodule McpNotes.Accounts.Token do
  @moduledoc """
  Resource for managing authentication tokens.
  
  This resource uses the AshAuthentication.TokenResource extension to handle
  token storage and management for user authentication sessions.
  """
  
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    domain: McpNotes.Accounts

  sqlite do
    table "tokens"
    repo McpNotes.Repo
  end
end
