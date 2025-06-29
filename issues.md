# Considerations

You have full control and can create the application from scratch.

You MUST use idiomatic Ash, and Ash resources.

After every two steps you will re-analyze code and usage rules to catch any mistakes.

# Required functionality

It's an MCP server developed using ash_ai. See usage for how to expose tooling and tools from MCP.

This MCP server will store projects and notes per each project. Projects and notes will be saved in the databse, the MCP server will provide tools to expose them.

There will be no UI at this time yet.

## Tools and functionality:

### List

- list_projects: return names of all projects, sorted alphabetically
- list_notes: returns all notes for all projects, sorted by creation time, descending
- list_notes_for_project: returns notes for specified project, sorted by creation time, descending

### Add

- add_project: add new project with specified name. If name already exists, add (sequence number) to project name
- add_note_to_project: add new note to specified project name

### Delete

- delete_project: remove project and all its notes
- delete_notes_for_project: remove notes for specified project, keep projects

### Stats

- stats: returns total number of projects, total number of notes, and a list of projects with number of notes per project

