defmodule McpNotes.Accounts.User do
  @moduledoc """
  User resource with API key authentication support.
  
  Users can authenticate using API keys through the AshAuthentication extension.
  Valid API keys are those that have not yet expired.
  """
  
  use Ash.Resource,
    otp_app: :mcp_notes,
    domain: McpNotes.Notes,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication]

  sqlite do
    table "users"
    repo McpNotes.Repo
  end

  authentication do
    tokens do
      enabled?(true)
      token_resource(McpNotes.Accounts.Token)
    end

    session_identifier(:unsafe)

    strategies do
      api_key :api_key do
        api_key_relationship(:valid_api_keys)
        api_key_hash_attribute(:api_key_hash)
      end
    end
  end

  actions do
    defaults [:read]

    read :sign_in_with_api_key do
      argument :api_key, :string, allow_nil?: false
      prepare AshAuthentication.Strategy.ApiKey.SignInPreparation
    end
  end

  attributes do
    uuid_v7_primary_key :id
  end

  relationships do
    has_many :valid_api_keys, McpNotes.Accounts.ApiKey do
      filter expr(valid)
    end
  end
end
