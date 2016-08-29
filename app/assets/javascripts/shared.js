$(function() {
  $('.alert').delay(10000).fadeOut(function() {
    $(this).remove(); 
  });
  $('#flash').delay(10000).fadeOut(function() {
    $(this).remove(); 
  });
});