//= require jquery
//= require jquery_ujs
//= require jquery_ui
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/project_monitor
//= require Coccyx
//= require moment.min

//= require_tree ./initializers

//= require backtraceHide
//= require versionCheck
//= require projectCheck

$(function() {
  BacktraceHide.init();
  VersionCheck.init();
  ProjectCheck.init();
});
