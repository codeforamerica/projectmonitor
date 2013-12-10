//= require jquery
//= require jquery_ujs
//= require jquery_ui
//= require underscore
//= require moment.min

//= require_tree ./initializers

//= require backtraceHide
//= require projectEdit
//= require versionCheck
//= require projectCheck

$(function() {
  ProjectEdit.init();
  BacktraceHide.init();
  VersionCheck.init();
  ProjectCheck.init();
});
