# Duplicate Preference Pick Validation - Fixed

## Problem
Users were able to submit duplicate preference pick values (e.g., using "6" for two different games), which violates the game rules where each preference pick value must be unique per week (except for bowl games).

## Root Causes Identified
1. **Client-side JavaScript not firing**: The validation logic had bugs preventing alerts from showing
2. **$.unique() method issue**: jQuery's `$.unique()` only works on DOM elements, not arrays of values
3. **Event binding issues**: Form submission events weren't properly bound
4. **Missing server-side alert**: Even when validation failed, users didn't see a JavaScript alert

## Solution Implemented

### Three Layers of Validation

#### 1. Client-Side: Dropdown Change Detection
**File**: `app/assets/javascripts/games.js` (lines 4-46)
- Triggers when user changes a pref_pick_int dropdown
- Checks for duplicates across all dropdowns in the current week's table
- Shows alert: "Error: You cannot use the same preference pick value twice..."
- Automatically resets the dropdown to blank
- **Skips validation for bowl games**

#### 2. Client-Side: Form Submission Prevention
**File**: `app/assets/javascripts/games.js` (lines 51-138)
- Two event handlers: `submit` and `ajax:before` for maximum compatibility
- Prevents form from submitting if duplicates detected
- Shows alert before submission attempt
- Uses `e.preventDefault()` and `e.stopImmediatePropagation()`
- **Skips validation for bowl games**

#### 3. Server-Side: Model Validation + Alert
**Files**: 
- `app/models/selection.rb` (lines 12, 24-45)
- `app/controllers/selections_controller.rb` (lines 75-77, 91-92)
- `app/views/selections/create.js.erb` (lines 4-6)
- `app/views/selections/update.js.erb` (lines 3-6)

- Validates uniqueness at database level
- Returns error message: "Pref pick int must be unique. You have already used X for another game this week."
- **Shows JavaScript alert** via AJAX response
- **Skips validation for bowl games** (checked via `week.bowl_game?`)

## Key Improvements Made

### Fixed Duplicate Detection Logic
**Before** (broken):
```javascript
if(values.length !== $.unique(values).length) // Doesn't work with value arrays!
```

**After** (working):
```javascript
var hasDuplicates = values.some(function(item, idx) {
    return values.indexOf(item) !== idx;
});
```

### Fixed Bowl Game Detection
**Before** (inconsistent):
```javascript
var isBowlGame = $currentRow.attr('data-bowl-game') === 'true';
```

**After** (reliable):
```javascript
var isBowlGame = $currentRow.data('bowl-game') === true || $currentRow.attr('data-bowl-game') === 'true';
```

### Added Server-Side Alerts
**Before**: Only flash message (easy to miss)
**After**: JavaScript alert popup + flash message
```erb
<% if @errors == true %>
  alert('<%= j flash.now[:notice] %>');
<% end %>
```

### Added Console Debugging
All validation steps now log to browser console for troubleshooting:
- "Games.js loaded - duplicate validation active"
- "Dropdown changed - validating duplicates"
- "Selected values: [1, 2, 3]"
- "Has duplicates? true/false"

## Files Modified

1. ✅ `app/assets/javascripts/games.js` - Fixed validation logic, added alerts, debugging
2. ✅ `app/models/selection.rb` - Server-side uniqueness validation (already in place)
3. ✅ `app/controllers/selections_controller.rb` - Error message handling (already in place)
4. ✅ `app/views/selections/create.js.erb` - Added alert on error
5. ✅ `app/views/selections/update.js.erb` - Added alert on error
6. ✅ `app/views/games/index.html.erb` - Data attributes for bowl game detection (already in place)

## Deployment Instructions

### For Production Deployment

1. **Commit and push changes**:
```bash
git add .
git commit -m "Fix: Prevent duplicate preference pick values with alerts"
git push origin master
```

2. **Deploy to production** (Heroku example):
```bash
git push heroku master
```

3. **Precompile assets** (if not automatic):
```bash
RAILS_ENV=production bundle exec rake assets:precompile
```

4. **Clear browser cache on production**:
   - Users should hard refresh: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+F5` (Windows)
   - Or clear Rails cache: `rails cache:clear`

### Verification Steps

1. **Open browser console** (F12 or Right-click > Inspect > Console)
2. **Look for**: "Games.js loaded - duplicate validation active"
3. **Test duplicate selection**:
   - Select "1" for first game
   - Try selecting "1" for second game
   - Should see alert immediately
4. **Test form submission**:
   - Select duplicates
   - Click Submit
   - Should see alert: "Error: You cannot use the same preference pick value twice..."
5. **Test bowl games**:
   - Duplicates should be ALLOWED
   - No alerts should appear

## Testing Checklist

- [ ] Regular week: Alert shows when selecting duplicate in dropdown
- [ ] Regular week: Alert shows when trying to submit with duplicates
- [ ] Regular week: Server rejects duplicates with alert if JS bypassed
- [ ] Bowl week: Duplicates are allowed (no alerts)
- [ ] Console shows validation logs
- [ ] Multiple weeks on same page work independently

## Bowl Games Exception

Bowl games explicitly allow duplicate preference pick values because there are more games than ranking numbers (1-13). The validation checks `week.bowl_game?` at all three layers:

1. Client JS checks: `data-bowl-game="true"` attribute
2. Server validation: `return if game.week&.bowl_game?`

## Rollback Plan

If issues occur, revert these files:
```bash
git revert HEAD
git push heroku master
```

Or restore from this commit: [current commit hash]

## Support

If duplicates still get through:
1. Check browser console for validation logs
2. Verify `games.js` is loaded: Look for "Games.js loaded" message
3. Check network tab: AJAX requests should be blocked before sending
4. Verify server-side: Duplicate saves should fail with error message

## Notes for Future Development

- Console.log statements can be removed once confirmed working in production
- Consider adding visual indicators (red border) on duplicate dropdowns
- Consider showing all validation errors in a modal instead of alerts
- Add unit tests for the duplicate detection logic

