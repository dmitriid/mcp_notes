defmodule McpNotesWeb.PageController do
  use McpNotesWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
