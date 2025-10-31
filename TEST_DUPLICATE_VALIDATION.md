# How to Test Duplicate Preference Pick Validation

## Quick Test (30 seconds)

1. **Open the picksheet** (games index page)
2. **Open browser console** (F12 or Right-click > Inspect > Console)
3. **Look for**: `Games.js loaded - duplicate validation active`
4. **Select "1" for first game's pref pick**
5. **Select "1" for second game's pref pick**
6. **Expected**: 
   - Alert popup: "Error: You cannot use the same preference pick value twice..."
   - Dropdown resets to blank
   - Console shows validation logs

## What You Should See

### Console Output (Normal Flow):
```
Games.js loaded - duplicate validation active
Dropdown changed - validating duplicates
Is bowl game? false
Selected values: ["1"]
Has duplicates? false
Dropdown changed - validating duplicates
Is bowl game? false
Selected values: ["1", "1"]
Has duplicates? true
```

### Alert Message:
```
Error: You cannot use the same preference pick value twice. Please select a unique amount for each game.
```

## Test Scenarios

### Scenario 1: Duplicate on Dropdown Change ✅
1. Select "5" for Game 1
2. Select "5" for Game 2
3. **Expected**: Alert appears immediately, Game 2 dropdown resets

### Scenario 2: Duplicate on Form Submit ✅
1. Select "3" for Game 1
2. Select "7" for Game 2  
3. Change Game 2 to "3" (same as Game 1)
4. Click "Submit" button
5. **Expected**: Alert appears, form does NOT submit

### Scenario 3: Server-Side Validation ✅
1. Using curl or Postman, send duplicate pref_pick_int values
2. **Expected**: Server returns error, shows alert via AJAX response

### Scenario 4: Bowl Games Allow Duplicates ✅
1. Go to a bowl game week
2. Select "1" for multiple games
3. **Expected**: NO alerts, duplicates allowed

## Troubleshooting

### "No alert appears"
- Check console for "Games.js loaded" message
- If missing: JavaScript not loading, check asset pipeline
- Clear browser cache: Cmd+Shift+R (Mac) or Ctrl+Shift+F5 (Windows)

### "Alert appears but form still submits"
- Check console for "Submit" or "Ajax:before" event logs
- Verify `e.preventDefault()` is being called
- Check if form has `data-remote="true"` attribute

### "Works locally but not in production"
- Precompile assets: `RAILS_ENV=production rake assets:precompile`
- Check Heroku logs: `heroku logs --tail`
- Verify games.js is in compiled application.js

### "Duplicates still saved to database"
- Server-side validation should catch this
- Check rails console: `Selection.last.errors.full_messages`
- Verify week is not marked as bowl_game

## Manual Database Check

```ruby
# Rails console
week = Week.find_by(week_number: "10")
user = User.find_by(username: "testuser")

# Find duplicate pref_pick_int values
selections = Selection.joins(:game)
  .where(user_id: user.id, games: { week_id: week.id })
  
duplicates = selections.group(:pref_pick_int)
  .having('count(*) > 1')
  .count

puts "Duplicates found: #{duplicates}"
```

## Success Criteria

✅ Alert shows on dropdown change
✅ Alert shows on form submit  
✅ Form submission is prevented
✅ Dropdown resets after duplicate selection
✅ Server rejects duplicates if client JS bypassed
✅ Bowl games allow duplicates
✅ Console shows validation logs

## Performance Check

The validation runs:
- On every dropdown change (instant)
- On form submit (instant)
- On server save (< 100ms)

No performance impact expected.

