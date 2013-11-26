describe "ProjectMonitor.Models.Project", ->
  it "should include child models", ->
    project = BackboneFactory.create("complete_project")

    expect(project.get("build")).toBeDefined()

  describe "#update", ->
    beforeEach ->
      @build_changed = jasmine.createSpy()

    describe "when the project contains only build information", ->
      beforeEach ->
        @project = BackboneFactory.create("project")
        @project.get("build").on("change", @build_changed)
        attributes = { build: { code: "NEW PROJ"} }
        @project.update(attributes)

      it "should update build model", ->
        expect(@project.get("build").get("code")).toEqual("NEW PROJ")

      it "should fire build change event", ->
        expect(@build_changed).toHaveBeenCalled()
