var ProjectEdit = {};
(function (o) {
  o.handleProjectTypeChange = function () {
    var $container = $('#field_container');
    var $buildSetup = $('#build_setup');
    var $disabled_fieldsets = $('fieldset:not(#' + $(this).val() + ')', $container);
    $disabled_fieldsets.addClass('hide');
    $(':input', $disabled_fieldsets).attr('disabled', true);

    var $enabled_fieldset = $('#' + $(this).val());
    $enabled_fieldset.removeClass('hide');
    $(':input', $enabled_fieldset).attr('disabled', false);

    var $branch_name = $('#branch_name');
    var $field_container = $('#field_container');
    if ( $(this).val() == "TravisProject" || $(this).val() == "SemaphoreProject") {
      $branch_name.removeClass('hide');
      $field_container.removeClass('hide');
    }
    else {
      $branch_name.addClass('hide');
      $field_container.addClass('hide');
    }

    if ($(this).val() == "TddiumProject") {
       $buildSetup.find('#project_webhooks_enabled_false').click();
       $buildSetup.find('#project_webhooks_enabled_true').prop('disabled', true);
    } else {
      $buildSetup.find('#project_webhooks_enabled_true').prop('disabled', false);
      $buildSetup.find('#project_webhooks_enabled_false').prop('checked', false);
    }

    var $auth_fields = $('.auth_field');
    if ( $(this).val() == "TravisProject" || $(this).val() == "SemaphoreProject") {
      $auth_fields.addClass('hide');
    }
    else {
      $auth_fields.removeClass('hide');
    }
  };

  var isEmpty = function(element) {
    return $(element).val() === "";
  }

  o.validateFeedUrl = function () {
    $('.success, .failure, .unconfigured, .empty_fields', '#polling').addClass('hide');

    if ($('#project_type').val() === "") {
      $('#build_status .unconfigured').removeClass('hide');
      return;
    }

    var $inputs = $('#field_container :input:not(.hide):not(.optional):enabled');
    if(_.some($inputs, isEmpty)){
      if(_.every($inputs, isEmpty)){
        $('#polling .unconfigured').removeClass('hide');
      }else{
        $('#polling .empty_fields').removeClass('hide');
      }
      return;
    }

    $('#polling .pending').removeClass('hide');
    $.ajax({
      url: "/projects/validate_build_info",
      type: "post",
      data: $('form').serialize(),
      success: function (result) {
        if (result.status) {
          $('#polling .pending').addClass('hide');
          $('#build_status .success').removeClass('hide');
        }
        else {
          $('#polling .pending').addClass('hide');
          $('#polling .failure').removeClass('hide').attr("title",result.error_type + ": '" + result.error_text + "'");
        }
      },
      error: function (result) {
        $('#polling .pending').addClass('hide');
        $('#polling .failure').removeClass('hide').attr("title","Server Error");
      }
    });
  };

  var handleParameterChange = function (event) {
    if (o.validateTrackerSetup() === false) {
      event.stopPropagation();
      event.preventDefault();
    }
  };

  o.toggleWebhooks = function () {
    if ($('input#project_webhooks_enabled_true:checked').length > 0) {
      if($("#project_type").val() != "TravisProject"){
        $('#field_container').addClass('hide');
      }

      $('fieldset#webhooks').removeClass('hide');
      $('fieldset#polling').addClass('hide');
    }
    else if ($('input#project_webhooks_enabled_false:checked').length > 0) {
      $('#field_container').removeClass('hide');
      $('fieldset#webhooks').addClass('hide');
      $('fieldset#polling').removeClass('hide');
    }
  };

  var showPasswordField = function () {
    $('#new_password').removeClass('hide');
    $('#change_password').addClass('hide');
    $('#new_password input').focus();
    $('#password_changed').val('true');
    return false;
  };

  o.init = function () {
    $('#project_tracker_auth_token, #project_tracker_project_id, input[type=submit]')
    .change(handleParameterChange);
    $('#project_type').change(o.handleProjectTypeChange);
    $('#field_container :input').change(o.validateFeedUrl);
    $('input[name="project[webhooks_enabled]"]').change(o.toggleWebhooks);
    $('#build_setup input.refresh').click(o.validateFeedUrl);
    $('#change_password a').click(showPasswordField);

    if ($('input[name="project[webhooks_enabled]"]').length > 0) { o.toggleWebhooks(); }

    var $project_online = $('#project_online');
    if ($project_online.length !== 0) {
      if ($project_online.val() === "1") {
        $('#build_status .success').removeClass('hide');
      } else {
        $('#polling .failure').removeClass('hide');
      }
    }

    var $tracker_online = $('#project_tracker_online');
    if ($tracker_online.length !== 0) {
      if ($tracker_online.val() === "1") {
        showTrackerSuccess();
      } else {
        o.validateTrackerSetup();
      }
    }
  };
})(ProjectEdit);
