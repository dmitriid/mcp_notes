defmodule McpNotes.Accounts do
  use Ash.Domain,
    otp_app: :mcp_notes

  resources do
    resource McpNotes.Accounts.ApiKey
    resource McpNotes.Accounts.Token
  end
end
