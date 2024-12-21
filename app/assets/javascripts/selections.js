$(function() {
  $('#load-more-btn').on('click', function() {
    const btn = $(this);
    const oldestWeekId = btn.data('oldest-week');
    
    btn.prop('disabled', true)
       .html('Loading...');
    
    $.get('/selections', {
      oldest_week: oldestWeekId,
      format: 'js'
    })
    .done(function(response) {
      if (response.trim().length > 0) {
        $('#selections-container').append(response);
        // Update the oldest week ID for next load
        const newOldestWeekId = btn.data('new-oldest-week');
        if (newOldestWeekId) {
          btn.data('oldest-week', newOldestWeekId);
        } else {
          btn.remove(); // No more data to load
        }
      } else {
        btn.remove(); // No more data to load
      }
    })
    .fail(function() {
      alert('Error loading more selections');
    })
    .always(function() {
      btn.prop('disabled', false)
         .html('Load More Selections');
    });
  });
}); 