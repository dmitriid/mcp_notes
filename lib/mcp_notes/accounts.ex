defmodule McpNotes.Accounts do
  @moduledoc """
  The Accounts context. Manages user accounts, authentication tokens, and API keys.
  """
  
  use Ash.Domain,
    otp_app: :mcp_notes

  resources do
    resource McpNotes.Accounts.ApiKey
    resource McpNotes.Accounts.Token
  end
end
