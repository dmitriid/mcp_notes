defmodule McpNotes.Accounts.Token do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    domain: McpNotes.Accounts

  sqlite do
    table "tokens"
    repo McpNotes.Repo
  end
end
