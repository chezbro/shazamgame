$(function() {

    function getSelections() {
        // Check if this is a bowl game row
        var $currentRow = $(this).closest('tr');
        var isBowlGame = $currentRow.attr('data-bowl-game') === 'true';
        
        // Only enforce uniqueness for non-bowl games
        if (isBowlGame) {
            return;
        }
        
        // Get all selected pref pick amounts in this week's table
        var $selects = $currentRow.closest('table').find('.pref_pick_int option:selected').not($(".pref_pick_int").find("option:contains('Select an Amount')"));
        var values = [];
  
        $selects.each(function() {
            if($(this).val()) {
                values.push($(this).val());
            }
        });
        
        if(!values.length) {
            alert('Please select a pref pick amount');
            return false;
        }
        
        // Check for duplicates
        if(values.length !== $.unique(values).length) {
            alert('Please Select a unique Pref Amount');
            $(this)[0].selectedIndex=0;
            return false;
        }
  
    }
  
    $('.pref_pick_int').change(getSelections);
    
    // Also validate on form submission
    $('form[data-remote="true"]').on('ajax:beforeSend', function(e) {
        var $form = $(this);
        var $submitBtn = $form.find('input[type="submit"]');
        var isBowlGame = $submitBtn.attr('data-bowl-game') === 'true';
        
        // Skip validation for bowl games
        if (isBowlGame) {
            return true;
        }
        
        // Get all selected pref pick amounts in this week's table
        var $table = $form.closest('table');
        var $selects = $table.find('.pref_pick_int option:selected').not($(".pref_pick_int").find("option:contains('Select an Amount')"));
        var values = [];
  
        $selects.each(function() {
            if($(this).val()) {
                values.push($(this).val());
            }
        });
        
        // Check for duplicates
        if(values.length !== $.unique(values).length) {
            e.preventDefault();
            alert('Please Select a unique Pref Amount before submitting');
            return false;
        }
        
        return true;
    });
  
  
  })