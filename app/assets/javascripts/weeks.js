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

  // Handle number of games - show/hide game fields
  function updateGameFieldsVisibility() {
    var numberOfGames = parseInt($('#week_number_of_games').val()) || 13;
    var gameFields = $('.game-field');
    
    gameFields.each(function() {
      var gameIndex = parseInt($(this).data('game-index')) || 0;
      if (gameIndex < numberOfGames) {
        $(this).show();
        // Enable all fields for visible games
        $(this).find('input, select').prop('disabled', false);
      } else {
        $(this).hide();
        // Disable all fields for hidden games so they're not submitted
        $(this).find('input, select').prop('disabled', true);
        // Clear values for hidden games
        $(this).find('select').val('');
      }
    });
  }
  
  // Note: Hidden games are already disabled, which prevents them from being submitted
  // The controller also filters out empty games, so this provides double protection

  $('#week_number_of_games').on('change input', updateGameFieldsVisibility);
  updateGameFieldsVisibility(); // Run on page load

  // Handle available points checkboxes - update hidden field
  function updateAvailablePointsHidden() {
    var checkedPoints = [];
    $('input[name="week[available_points_checkboxes][]"]:checked').each(function() {
      checkedPoints.push($(this).val());
    });
    // Sort descending (13, 12, 11, ...)
    checkedPoints.sort(function(a, b) { return b - a; });
    $('#week_available_points_hidden').val(checkedPoints.join(','));
  }

  $('input[name="week[available_points_checkboxes][]"]').on('change', updateAvailablePointsHidden);
  updateAvailablePointsHidden(); // Run on page load
});
