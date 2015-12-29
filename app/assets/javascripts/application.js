//= require jquery
//= require jquery_ujs
//= require casino
//= require bootstrap
//= require jasny-bootstrap
//= require turbolinks
//= require_tree .

$(function() {
  function _preview_orgin() {
    $("#user-image .fileinput-preview").html(function() {
      if($(this).data('origin') !== undefined) {
        return '<img src=' + $(this).data('origin') + '>';
      }
    });
  }

  _preview_orgin();
  $("#user-image").on("clear.bs.fileinput", function(e) {
    e.stopPropagation();
    _preview_orgin();
  });
});
