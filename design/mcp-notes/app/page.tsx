"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import {
  ChevronLeft,
  FileText,
  FolderOpen,
  Calendar,
  Plus,
  Search,
  Filter,
  BookOpen,
  Lightbulb,
  Target,
  Users,
  Edit,
  Trash2,
  Menu,
} from "lucide-react"
import data from "@/data/data.json"

export default function NotesApp() {
  const [selectedProject, setSelectedProject] = useState<number | null>(null)
  const [expandedNote, setExpandedNote] = useState<number | null>(null)
  const [sidebarOpen, setSidebarOpen] = useState(false)

  const { projects, notesByProject } = data
  const selectedProjectData = selectedProject ? projects.find((p) => p.id === selectedProject) : null
  const projectNotes = selectedProject
    ? notesByProject[selectedProject.toString() as keyof typeof notesByProject] || []
    : []

  const getProjectIcon = (projectId: number) => {
    const icons = [BookOpen, Lightbulb, Target, Users]
    return icons[(projectId - 1) % icons.length]
  }

  const SidebarContent = () => (
    <div className="space-y-2">
      <div className="text-xs font-medium text-gray-600 uppercase tracking-wider mb-4">Navigation</div>

      <Button
        variant={!selectedProject ? "secondary" : "ghost"}
        className="w-full justify-start text-left text-gray-700 hover:bg-gray-200"
        onClick={() => {
          setSelectedProject(null)
          setSidebarOpen(false)
        }}
      >
        <FolderOpen className="w-4 h-4 mr-3" />
        All Projects
      </Button>

      <div className="pt-4">
        <div className="text-xs font-medium text-gray-600 uppercase tracking-wider mb-3">Recent Projects</div>
        {projects.slice(0, 3).map((project) => {
          const IconComponent = getProjectIcon(project.id)
          return (
            <Button
              key={project.id}
              variant={selectedProject === project.id ? "secondary" : "ghost"}
              className="w-full justify-start text-left mb-1 h-auto py-2 text-gray-700 hover:bg-gray-200"
              onClick={() => {
                setSelectedProject(project.id)
                setSidebarOpen(false)
              }}
            >
              <IconComponent className="w-4 h-4 mr-3 text-purple-600 flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="truncate text-sm font-medium">{project.name}</div>
                <div className="text-xs text-gray-500">{project.noteCount} notes</div>
              </div>
            </Button>
          )
        })}
      </div>
    </div>
  )

  return (
    <div className="min-h-screen" style={{ backgroundColor: "#f8f8fa" }}>
      {/* Container with proper padding */}
      <div className="max-w-7xl mx-auto">
        {/* Header on gray background */}
        <div className="px-4 sm:px-6 lg:px-8 py-4 sm:py-6 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2 sm:space-x-4">
              {/* Mobile menu button */}
              <Sheet open={sidebarOpen} onOpenChange={setSidebarOpen}>
                <SheetTrigger asChild>
                  <Button variant="ghost" size="sm" className="lg:hidden -ml-2">
                    <Menu className="w-5 h-5" />
                  </Button>
                </SheetTrigger>
                <SheetContent side="left" className="w-64 p-6" style={{ backgroundColor: "#f8f8fa" }}>
                  <SidebarContent />
                </SheetContent>
              </Sheet>

              {selectedProject ? (
                <>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setSelectedProject(null)}
                    className="text-gray-700 hover:text-gray-900 hover:bg-gray-200 -ml-2"
                  >
                    <ChevronLeft className="w-4 h-4 mr-1" />
                    <span className="hidden sm:inline">Back to Home</span>
                    <span className="sm:hidden">Back</span>
                  </Button>
                </>
              ) : (
                <h1 className="text-xl sm:text-2xl font-semibold text-gray-900">Notes</h1>
              )}
            </div>

            <div className="flex items-center space-x-2 sm:space-x-3">
              <Button variant="outline" size="sm" className="text-gray-700 border-gray-300 bg-white hover:bg-gray-50">
                <Search className="w-4 h-4 sm:mr-2" />
                <span className="hidden sm:inline">Search</span>
              </Button>
              <Button size="sm" className="bg-purple-600 hover:bg-purple-700 text-white">
                <Plus className="w-4 h-4 sm:mr-2" />
                <span className="hidden sm:inline">New {selectedProject ? "Note" : "Project"}</span>
              </Button>
            </div>
          </div>
        </div>

        <div className="flex">
          {/* Desktop Sidebar */}
          <div className="hidden lg:block w-64 p-6">
            <SidebarContent />
          </div>

          {/* Main Content */}
          <div className="flex-1 p-4 sm:p-6 lg:p-8">
            {!selectedProject ? (
              /* Projects Grid */
              <div>
                <div className="mb-6 sm:mb-8">
                  <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Your Projects</h2>
                  <p className="text-gray-700 text-base sm:text-lg">
                    Organize your notes and ideas by project for better focus and collaboration.
                  </p>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
                  {projects.map((project) => {
                    const IconComponent = getProjectIcon(project.id)
                    return (
                      <Card
                        key={project.id}
                        className="cursor-pointer hover:shadow-lg transition-all duration-200 border-gray-200 hover:border-purple-200 group bg-white"
                        onClick={() => setSelectedProject(project.id)}
                      >
                        <CardHeader className="pb-3 sm:pb-4">
                          <div className="flex items-start justify-between">
                            <div className="flex items-center space-x-3 flex-1 min-w-0">
                              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-purple-100 rounded-xl flex items-center justify-center group-hover:bg-purple-200 transition-colors flex-shrink-0">
                                <IconComponent className="w-5 h-5 sm:w-6 sm:h-6 text-purple-600" />
                              </div>
                              <div className="min-w-0 flex-1">
                                <CardTitle className="text-lg sm:text-xl text-gray-900 group-hover:text-purple-900 transition-colors truncate">
                                  {project.name}
                                </CardTitle>
                                <div className="flex flex-col sm:flex-row sm:items-center sm:space-x-4 mt-2 text-sm text-gray-500 space-y-1 sm:space-y-0">
                                  <div className="flex items-center space-x-1">
                                    <FileText className="w-4 h-4" />
                                    <span>{project.noteCount} notes</span>
                                  </div>
                                  <div className="flex items-center space-x-1">
                                    <Calendar className="w-4 h-4" />
                                    <span>{project.lastUpdated}</span>
                                  </div>
                                </div>
                              </div>
                            </div>
                            <div className="flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity ml-2">
                              <Button
                                variant="ghost"
                                size="sm"
                                className="h-8 w-8 p-0 text-gray-500 hover:text-blue-600"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  console.log("Rename project", project.id)
                                }}
                              >
                                <Edit className="w-4 h-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                className="h-8 w-8 p-0 text-gray-500 hover:text-red-600"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  console.log("Delete project", project.id)
                                }}
                              >
                                <Trash2 className="w-4 h-4" />
                              </Button>
                            </div>
                          </div>
                        </CardHeader>
                        <CardContent className="pt-0">
                          <CardDescription className="text-gray-600 leading-relaxed text-sm sm:text-base">
                            {project.description}
                          </CardDescription>
                        </CardContent>
                      </Card>
                    )
                  })}
                </div>
              </div>
            ) : (
              /* Project Notes View */
              <div>
                <div className="mb-6 sm:mb-8">
                  <Card className="bg-white p-4 sm:p-6 border-gray-200">
                    <div className="flex flex-col sm:flex-row sm:items-center space-y-4 sm:space-y-0 sm:space-x-4 mb-4">
                      {(() => {
                        const IconComponent = getProjectIcon(selectedProject)
                        return (
                          <div className="w-12 h-12 sm:w-16 sm:h-16 bg-purple-100 rounded-2xl flex items-center justify-center flex-shrink-0">
                            <IconComponent className="w-6 h-6 sm:w-8 sm:h-8 text-purple-600" />
                          </div>
                        )
                      })()}
                      <div className="min-w-0 flex-1">
                        <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 truncate">
                          {selectedProjectData?.name}
                        </h2>
                        <p className="text-gray-600 text-base sm:text-lg mt-1">{selectedProjectData?.description}</p>
                      </div>
                    </div>

                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
                      <div className="flex flex-col sm:flex-row sm:items-center sm:space-x-6 text-sm text-gray-500 space-y-2 sm:space-y-0">
                        <div className="flex items-center space-x-2">
                          <FileText className="w-4 h-4" />
                          <span>{projectNotes.length} notes</span>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Calendar className="w-4 h-4" />
                          <span>Last updated {selectedProjectData?.lastUpdated}</span>
                        </div>
                      </div>

                      <Button
                        variant="outline"
                        size="sm"
                        className="text-gray-600 border-gray-200 bg-transparent self-start sm:self-auto"
                      >
                        <Filter className="w-4 h-4 mr-2" />
                        Filter
                      </Button>
                    </div>
                  </Card>
                </div>

                <div className="space-y-4">
                  {projectNotes.map((note) => (
                    <Card
                      key={note.id}
                      className="border-gray-200 hover:shadow-md transition-all duration-200 hover:border-purple-200 bg-white group"
                    >
                      <CardHeader
                        className="cursor-pointer"
                        onClick={() => setExpandedNote(expandedNote === note.id ? null : note.id)}
                      >
                        <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between space-y-4 sm:space-y-0">
                          <div className="flex-1 min-w-0">
                            <CardTitle className="text-lg sm:text-xl text-gray-900 mb-2">{note.title}</CardTitle>
                            <CardDescription className="text-gray-600 leading-relaxed text-sm sm:text-base">
                              {expandedNote === note.id ? (
                                <div className="whitespace-pre-wrap pt-4 text-gray-800 border-t border-gray-100 mt-4">
                                  {note.content}
                                </div>
                              ) : (
                                note.preview
                              )}
                            </CardDescription>
                          </div>

                          <div className="flex flex-row sm:flex-col items-start sm:items-end justify-between sm:justify-start sm:ml-6 sm:text-right flex-shrink-0">
                            <div className="flex items-center space-x-1 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity mb-0 sm:mb-3 order-2 sm:order-1">
                              <Button
                                variant="ghost"
                                size="sm"
                                className="h-8 w-8 p-0 text-gray-500 hover:text-blue-600"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  console.log("Edit note", note.id)
                                }}
                              >
                                <Edit className="w-4 h-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                className="h-8 w-8 p-0 text-gray-500 hover:text-red-600"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  console.log("Delete note", note.id)
                                }}
                              >
                                <Trash2 className="w-4 h-4" />
                              </Button>
                            </div>

                            <div className="order-1 sm:order-2">
                              <div className="text-sm text-gray-500 mb-2 sm:mb-3">{note.createdAt}</div>
                              <div className="flex flex-wrap gap-2 justify-start sm:justify-end">
                                {note.tags.map((tag) => (
                                  <Badge
                                    key={tag}
                                    variant="secondary"
                                    className="text-xs bg-purple-100 text-purple-700 hover:bg-purple-200"
                                  >
                                    {tag}
                                  </Badge>
                                ))}
                              </div>
                            </div>
                          </div>
                        </div>
                      </CardHeader>
                    </Card>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
