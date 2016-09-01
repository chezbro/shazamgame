$(function() {

    function getSelections() {
      var $selects = $('.pref_pick_int option:selected').not($(".pref_pick_int").find("option:contains('Select an Amount')")  )
          values = [];

        $($selects).each(function() {
            if($(this).val()) {
                values.push($(this).val());        
            }
        });
          if(!values.length) {
              alert('Please select a new pref pick amount');
              return false;
          }
        if(values.length < $selects.length || $.unique(values).length < $selects.length) {
          alert('Please Select a unique Pref Amount');
          return false;
        }

  }

$('.pref_pick_int').change(getSelections);

})


