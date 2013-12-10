describe "ProjectMonitor.Views.HomeView", ->
  beforeEach ->
    @project = BackboneFactory.create('project')
    @projects = new ProjectMonitor.Collections.Projects([@project])
    @view = new ProjectMonitor.Views.HomeView(collection: @projects)

  it "should render one tile", ->
    expect(@view.render().$el.find("article").length).toEqual(1)

  it "should render standalong tile", ->
    expect(@view.render().$el).toContain("li.project")

  it "should render only the latest ten builds", ->
    expect(@view.render().$el.find('.statuses li').size()).toEqual(10)

  describe "when the collection triggers an add event", ->
    it 'should render two tiles', ->
      expect(@view.render().$el.find("article").length).toEqual(1)
      @projects.add(BackboneFactory.create('project'))
      expect(@view.render().$el.find("article").length).toEqual(2)

    it "should render only two tiles when we try to add an already-existing tile", ->
      @projects.add(@project)
      expect(@view.render().$el.find("article").length).toEqual(1)

  describe "when the collection triggers a remove event", ->
    it "should render one tile", ->
      expect(@view.render().$el.find("article").length).toEqual(1)
      @projects.remove(@project)
      expect(@view.render().$el.find("article").length).toEqual(0)

    it 'should render one tile if the removed model has no corresponding subview', ->
      @projects.remove(BackboneFactory.create('project'))
      expect(@view.render().$el.find("article").length).toEqual(1)

  describe "when the collection triggers a reset event", ->

    it "should stay the same if nothing has changed", ->
      @projects.trigger('reset')
      expect(@view.render().$el.find("article").length).toEqual(1)

    it "should add projects if they are added", ->
      @projects.add(BackboneFactory.create('project'), silent: true)
      expect(@view.render().$el.find("article").length).toEqual(1)
      @projects.trigger('reset')
      expect(@view.render().$el.find("article").length).toEqual(2)

    it "should remove projects if they are removed", ->
      @projects.remove(@project, silent: true)
      expect(@view.render().$el.find("article").length).toEqual(1)
      @projects.trigger('reset')
      expect(@view.render().$el.find("article").length).toEqual(0)

