$(function() {
    console.log('Games.js loaded - duplicate validation active');

    function getSelections() {
        console.log('Dropdown changed - validating duplicates');
        // Check if this is a bowl game row
        var $currentRow = $(this).closest('tr');
        var isBowlGame = $currentRow.data('bowl-game') === true || $currentRow.attr('data-bowl-game') === 'true';
        
        console.log('Is bowl game?', isBowlGame);
        
        // Only enforce uniqueness for non-bowl games
        if (isBowlGame) {
            console.log('Bowl game - skipping duplicate validation');
            return;
        }
        
        // Get all selected pref pick amounts in this week's table
        var $table = $currentRow.closest('table');
        var $selects = $table.find('.pref_pick_int');
        var values = [];
  
        $selects.each(function() {
            var val = $(this).val();
            if(val && val !== '' && val !== 'Select an Amount') {
                values.push(val);
            }
        });
        
        console.log('Selected values:', values);
        
        // Check for duplicates using a more reliable method
        var hasDuplicates = values.some(function(item, idx) {
            return values.indexOf(item) !== idx;
        });
        
        console.log('Has duplicates?', hasDuplicates);
        
        if(hasDuplicates) {
            alert('Error: You cannot use the same preference pick value twice. Please select a unique amount for each game.');
            // Reset the dropdown that was just changed
            this.selectedIndex = 0;
            return false;
        }
  
    }
  
    $('.pref_pick_int').on('change', getSelections);
    
    // Also validate on form submission
    $(document).on('submit', 'form[data-remote="true"]', function(e) {
        console.log('Form submit event triggered');
        var $form = $(this);
        var $submitBtn = $form.find('input[type="submit"]');
        var isBowlGame = $submitBtn.data('bowl-game') === true || $submitBtn.attr('data-bowl-game') === 'true';
        
        console.log('Submit - Is bowl game?', isBowlGame);
        
        // Skip validation for bowl games
        if (isBowlGame) {
            console.log('Bowl game - allowing submission');
            return true;
        }
        
        // Get all selected pref pick amounts in this week's table
        var $table = $form.closest('table');
        var $selects = $table.find('.pref_pick_int');
        var values = [];
  
        $selects.each(function() {
            var val = $(this).val();
            if(val && val !== '' && val !== 'Select an Amount') {
                values.push(val);
            }
        });
        
        console.log('Submit - Selected values:', values);
        
        // Check for duplicates using a more reliable method
        var hasDuplicates = values.some(function(item, idx) {
            return values.indexOf(item) !== idx;
        });
        
        console.log('Submit - Has duplicates?', hasDuplicates);
        
        if(hasDuplicates) {
            e.preventDefault();
            e.stopImmediatePropagation();
            alert('Error: You cannot use the same preference pick value twice. Please ensure each game has a unique preference pick amount.');
            return false;
        }
        
        return true;
    });
    
    // Use rails-ujs event as fallback
    $(document).on('ajax:before', 'form[data-remote="true"]', function(e) {
        console.log('Ajax:before event triggered');
        var $form = $(this);
        var $submitBtn = $form.find('input[type="submit"]');
        var isBowlGame = $submitBtn.data('bowl-game') === true || $submitBtn.attr('data-bowl-game') === 'true';
        
        console.log('Ajax:before - Is bowl game?', isBowlGame);
        
        // Skip validation for bowl games
        if (isBowlGame) {
            console.log('Bowl game - allowing AJAX submission');
            return true;
        }
        
        // Get all selected pref pick amounts in this week's table
        var $table = $form.closest('table');
        var $selects = $table.find('.pref_pick_int');
        var values = [];
  
        $selects.each(function() {
            var val = $(this).val();
            if(val && val !== '' && val !== 'Select an Amount') {
                values.push(val);
            }
        });
        
        console.log('Ajax:before - Selected values:', values);
        
        // Check for duplicates
        var hasDuplicates = values.some(function(item, idx) {
            return values.indexOf(item) !== idx;
        });
        
        console.log('Ajax:before - Has duplicates?', hasDuplicates);
        
        if(hasDuplicates) {
            alert('Error: You cannot use the same preference pick value twice. Please ensure each game has a unique preference pick amount.');
            return false;
        }
        
        return true;
    });
  
  
  })