$(function() {
  $(".submit-scores").on("click", function() {
    $(".scores-form").submit();
  });

  function toggleBowlGameFields() {
    var isBowlGame = $('#week_bowl_game').is(':checked');
    $('.bowl-game-name').toggle(isBowlGame);
    $('.regular-game-number').toggle(!isBowlGame);
  }

  $('#week_bowl_game').on('change', toggleBowlGameFields);
  toggleBowlGameFields(); // Run on page load
});
