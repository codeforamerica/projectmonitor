class ProjectMonitor.Models.Project extends Backbone.Model
  urlRoot: '/projects'
  paramRoot: 'project'

  initialize: (attributes, options) ->
    @id = attributes.project_id
    @set build: new ProjectMonitor.Models.Build(attributes.build) if attributes.build?
  
  update: (attributes) ->
    unless @get("aggregate")
      @get("build").set(attributes.build) if attributes.build?