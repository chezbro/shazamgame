$(function() {
    console.log('Games.js loaded - duplicate validation active');

    function getSelections() {
        console.log('Dropdown changed - validating duplicates');
        // Check if this is a bowl game row
        var $currentRow = $(this).closest('tr');
        var isBowlGame = $currentRow.data('bowl-game') === true || $currentRow.attr('data-bowl-game') === 'true';
        
        console.log('Is bowl game?', isBowlGame);
        
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
            // Show alert for both bowl games and regular games
            // (Server-side validation allows duplicates for bowl games, but we still want to warn users)
            if (isBowlGame) {
                alert('Warning: You have selected the same preference pick value multiple times. For bowl games, you may use each ranking number twice, but please be aware of your selections.');
                // Reset the dropdown that was just changed
                this.selectedIndex = 0;
            } else {
                alert('Error: You cannot use the same preference pick value twice. Please select a unique amount for each game.');
                // Reset the dropdown that was just changed
                this.selectedIndex = 0;
                return false;
            }
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
            // Show alert for both bowl games and regular games
            // (Server-side validation allows duplicates for bowl games, but we still want to warn users)
            if (isBowlGame) {
                alert('Warning: You have selected the same preference pick value multiple times. For bowl games, you may use each ranking number twice, but please be aware of your selections.');
                // Allow submission for bowl games
                return true;
            } else {
                e.preventDefault();
                e.stopImmediatePropagation();
                alert('Error: You cannot use the same preference pick value twice. Please ensure each game has a unique preference pick amount.');
                return false;
            }
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
            // Show alert for both bowl games and regular games
            // (Server-side validation allows duplicates for bowl games, but we still want to warn users)
            if (isBowlGame) {
                alert('Warning: You have selected the same preference pick value multiple times. For bowl games, you may use each ranking number twice, but please be aware of your selections.');
                // Allow submission for bowl games
                return true;
            } else {
                alert('Error: You cannot use the same preference pick value twice. Please ensure each game has a unique preference pick amount.');
                return false;
            }
        }
        
        return true;
    });
  
  
  })