describe("project edit", function() {
  beforeEach(function() {
    jasmine.Ajax.useMock();
  });

  describe("Feed URL fields", function() {
    beforeEach(function() {
      setFixtures(
        '<select id="project_type" name="project[type]">' +
        '  <option value=""></option>' +
        '  <option value="CruiseControlProject">Cruise Control Project</option>' +
        '  <option value="JenkinsProject">Jenkins Project</option>' +
        '  <option value="TravisProject">TravisProject</option>' +
        '  <option value="SemaphoreProject">SemaphoreProject</option>' +
        '  <option value="TddiumProject">TddiumProject</option>' +
        '</select>' +
        '<div id="field_container" class="hide">' +
        '  <fieldset id="CruiseControlProject">' +
        '    <input id="project_cruise_control_rss_feed_url" name="project[cruise_control_rss_feed_url]"/>' +
        '  </fieldset>' +
        '  <fieldset class="hide" id="JenkinsProject">' +
        '    <input id="project_jenkins_base_url" name="project[jenkins_base_url]"/>' +
        '    <input id="project_jenkins_build_name" name="project[jenkins_build_name]" type="text">' +
        '  </fieldset>' +
        '  <fieldset class="hide" id="TddiumProject">' +
        '    <input id="project_tddium_auth_token" name="project[tddium_auth_token]" size="30" type="text">' +
        '    <input id="project_tddium_project_name" name="project[tddium_project_name]" placeholder="repo_name (branch_name)" size="30" type="text">' +
        '  </fieldset>' +
        '  <input id="project_auth_username" name="project[auth_username]" type="text">' +
        '  <input id="project_auth_password" name="project[auth_password]" type="text" class="optional">' +
        '</div>' +
        '<fieldset id="polling">' +
        '  <input id="project_online" name="project[online]" type="hidden"/>' +
        '  <div id="build_status">' +
        '    <span class="hide"/>' +
        '    <span class="unconfigured hide"/>' +
        '    <span class="failure hide"/>' +
        '    <span class="success hide"/>' +
        '  </div>' +
        '</fieldset>' +
        '<fieldset id="build_setup">' +
        '  <input type="radio" id="project_webhooks_enabled_true"/>' +
        '  <input type="radio" id="project_webhooks_enabled_false"/>' +
        '  <p class="hide" id="branch_name">' +
        '    <label for="project_build_branch">Branch Name</label>' +
        '    <input id="project_build_branch" name="project[build_branch]" size="30" type="text" class="">' +
        '  </p>' +
        '</fieldset>');
    });

    describe("changing available inputs", function () {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
      });

      it("makes the Jenkins project fieldset visible", function() {
        expect($('fieldset#JenkinsProject')).toExist();
        expect($('fieldset#JenkinsProject').hasClass('hide')).toBeFalsy();
        expect($('#project_jenkins_base_url').attr('disabled')).toBeFalsy();
      });

      it("makes the Cruise Control project fieldset invisible", function() {
        expect($('fieldset#CruiseControlProject').hasClass('hide')).toBeTruthy();
        expect($('#project_cruise_control_rss_feed_url').attr('disabled')).toBeTruthy();
      });
    });

    describe("showing the branch field", function() {
      beforeEach(function() {
        ProjectEdit.init();
      });

      it("shows the branch field when a Travis Project is selected", function() {
        $('#project_type').val('TravisProject').change();
        expect($('#branch_name')).toExist();
        expect($('#branch_name').hasClass('hide')).toBeFalsy();
      });

      it("shows the branch field when a Semaphore Project is selected", function() {
        $('#project_type').val('SemaphoreProject').change();
        expect($('#branch_name')).toExist();
        expect($('#branch_name').hasClass('hide')).toBeFalsy();
      });

      it("shows the field_container when a Travis Project is selected", function() {
        $('#project_type').val('TravisProject').change();
        expect($('#field_container')).toExist();
        expect($('#field_container').hasClass('hide')).toBeFalsy();
      });

      it("hides the branch field when another project type is selected", function() {
        $('#project_type').val('JenkinsProject').change();
        expect($('#branch_name').hasClass('hide')).toBeTruthy();
      });

      it("hides the field_container when another project type is selected", function() {
        $('#project_type').val('JenkinsProject').change();
        expect($('#field_container').hasClass('hide')).toBeTruthy();
      });
    });

    describe("disable webhook and default to polling on projects that do not support webhooks", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('TddiumProject').change();
      });

      it("Tddium projects", function() {
        expect($('#project_webhooks_enabled_true').attr('disabled')).toBeTruthy();
        expect($('#project_webhooks_enabled_false').prop('checked')).toBeTruthy();
      });
    });

    describe("when changing from webhooks to polling", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
        $('#project_webhooks_enabled_true').click();
        $('#project_type').val('TddiumProject').change();
      });
      it("should dispaly the Tddium fieldset", function() {
        expect($('fieldset#TddiumProject').hasClass('hide')).toBeFalsy();
        expect($('fieldset#polling').hasClass('hide')).toBeFalsy();
      });
    });

    describe("when the project is already marked as online", function() {
      beforeEach(function() {
        $('#project_online').val("1");
        ProjectEdit.init();
      });

      it("should display the success message", function() {
        expect($("#build_status .success")).not.toHaveClass("hide");
      });
    });

    describe("when all the build configuration inputs are present", function() {
      describe("and the tracker returns a parseable build status", function() {
        beforeEach(function() {
          spyOn($, 'ajax').andCallFake(function (opts) {
            opts.success({status: true});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_auth_username').val('alice').change();
        });

        it("should display the success message", function() {
          expect($("#build_status .success")).not.toHaveClass("hide");
        });
      });

      describe("and the tracker does not return a parseable build status", function() {
        beforeEach(function() {
          spyOn($, 'ajax').andCallFake(function (opts) {
            opts.success({status: false, error_type: "Error Type", error_text: "Error Text"});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_cruise_control_rss_feed_url').val("foobar").change();
          $('#project_auth_username').val('alice').change();
        });

        it("should display the server's error message", function() {
          expect($("#build_status .failure")).not.toHaveClass("hide");
          expect($("#build_status .failure").attr('title')).toBe("Error Type: 'Error Text'");
        });
      });

      describe("and the server does not respond correctly", function() {
        beforeEach(function() {
          spyOn($, 'ajax').andCallFake(function (opts) {
            opts.error({status: 404});
          });
          ProjectEdit.init();
          $('#project_type').val('JenkinsProject').change();
          $('#project_jenkins_base_url').val("foobar").change();
          $('#project_jenkins_build_name').val("grok").change();
          $('#project_auth_username').val('user').change();
        });

        it("should display the failure message", function() {
          expect($("#build_status .failure")).not.toHaveClass("hide");
        });
        it("should add a tooltip indicating a server error", function() {
          expect($('#build_status .failure').attr('title')).toBe('Server Error');
        });
      });
    });

    describe("when some of the build configuration inputs are blank", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
        $('#project_jenkins_base_url').val("").change();
        $('#project_jenkins_build_name').val("foobar").change();
      });

      it("should display the Some Fields Empty message", function() {
        expect($("#build_status .empty_fields")).not.toHaveClass("hide");
      });
    });

    describe("when the project type is blank but an input is filled in", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_auth_username').val('alice').change();
      });

      it("should display the unconfigured message", function() {
        expect($("#build_status .unconfigured")).not.toHaveClass("hide");
      });
    });

    describe("when all of the build configuration inputs are blank", function() {
      beforeEach(function() {
        ProjectEdit.init();
        $('#project_type').val('JenkinsProject').change();
        $('#project_jenkins_base_url').val("").change();
      });

      it("should display the unconfigured message", function() {
        expect($("#build_status .unconfigured")).not.toHaveClass("hide");
      });
    });
  });
  describe("toggling payload strategy", function() {


    describe("when not a travis build", function(){
      beforeEach(function() {
        setFixtures('<div id="project_type"></div>' +
                    '<div id="field_container"></div>' +
                    '<input checked="checked" id="project_webhooks_enabled_true" name="project[webhooks_enabled]" type="radio" value="true">' +
                    '<input id="project_webhooks_enabled_false" name="project[webhooks_enabled]" type="radio" value="false">' +
                    '<fieldset id="webhooks" /><fieldset id="polling" />')
        ProjectEdit.init();
      });

      it("should toggle webhooks and polling when checked", function() {
        expect($('#webhooks')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).toHaveClass('hide');

        $('input#project_webhooks_enabled_false').prop('checked', true);
        $('input#project_webhooks_enabled_true').removeAttr('checked').change();
        expect($('#webhooks')).toHaveClass('hide');
        expect($('#polling')).not.toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');

        $('input#project_webhooks_enabled_false').removeAttr('checked');
        $('input#project_webhooks_enabled_true').prop('checked', true).change();
        expect($('#webhooks')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).toHaveClass('hide');
      });
    })

    describe("when a travis build", function(){
      beforeEach(function() {
        setFixtures('<div id="project_type"></div>' +
                    '<div id="field_container"></div>' +
                    '<input checked="checked" id="project_webhooks_enabled_true" name="project[webhooks_enabled]" type="radio" value="true">' +
                    '<input id="project_webhooks_enabled_false" name="project[webhooks_enabled]" type="radio" value="false">' +
                    '<fieldset id="webhooks" /><fieldset id="polling" />')
        $('#project_type').val("TravisProject")
        ProjectEdit.init();
      });

      it("should toggle webhooks and polling when checked", function() {
        expect($('#webhooks')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');

        $('input#project_webhooks_enabled_false').prop('checked', true);
        $('input#project_webhooks_enabled_true').removeAttr('checked').change();
        expect($('#webhooks')).toHaveClass('hide');
        expect($('#polling')).not.toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');

        $('input#project_webhooks_enabled_false').removeAttr('checked');
        $('input#project_webhooks_enabled_true').prop('checked', true).change();
        expect($('#webhooks')).not.toHaveClass('hide');
        expect($('#polling')).toHaveClass('hide');
        expect($('#field_container')).not.toHaveClass('hide');
      });
    })
  });
});
