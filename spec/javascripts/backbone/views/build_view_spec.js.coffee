describe "ProjectMonitor.Views.BuildView", ->
  describe "common behavior", ->
    beforeEach ->
      project = BackboneFactory.create("project")
      @build = project.get("build")
      @view = new ProjectMonitor.Views.BuildView(model: @build)

    describe "status", ->
      describe "when the build succeeded", ->
        beforeEach ->
          @build.set(status: "success")
          setFixtures(@view.render().$el)

        it "should have success class", ->
          expect($(".build")).toHaveClass("success")

      describe "when the build failed", ->
        beforeEach ->
          @build.set(status: "failure")
          setFixtures(@view.render().$el)

        it "should have failed class", ->
          expect($(".build")).toHaveClass("failure")

    describe "build", ->
      beforeEach ->
        publishedAt = moment().subtract('days', 4).format()
        @build.set("published_at", publishedAt)
        setFixtures(@view.render().$el)

      it "should have an article", ->
        expect($("article")).toExist()

      it "should include the build class", ->
        expect($("article")).toHaveClass('build')

      it "should include the code", ->
        expect($(".code")).toHaveText(@build.get("code"))

      it "should include the history", ->
        expect($(".statuses li:nth-child(1)")).toHaveClass("success")
        expect($(".statuses li:nth-child(2)")).toHaveClass("failure")
        expect($(".statuses li:nth-child(3)")).toHaveClass("success")

      it "should include the last build time", ->
        expect($(".time-since-last-build")).toHaveText("4d")

  describe "when build model changes", ->
    it "should render the view", ->
      build = BackboneFactory.create("project").get("build")
      spyOn(ProjectMonitor.Views.BuildView.prototype, "render")
      view = new ProjectMonitor.Views.BuildView(model: build)
      build.set({code: "NEW CODE"})
      expect(ProjectMonitor.Views.BuildView.prototype.render).toHaveBeenCalled()
