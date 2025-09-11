# Production Deployment Guide - Score Verification

## Overview
This guide will help you safely verify and fix score discrepancies before deploying to production.

## Step 1: Backup Production Data
**CRITICAL: Always backup your production database first!**

```bash
# Connect to production server and create database backup
pg_dump your_production_db > production_backup_$(date +%Y%m%d_%H%M%S).sql
```

## Step 2: Run Verification Script Locally
Test the verification script on your development environment first:

```bash
# Make sure you're using the correct Ruby version
rvm use 3.2.2

# Run the verification script
bundle exec rake verification:verify_scores
```

## Step 3: Test Score Fix Script (Dry Run)
Before applying any fixes, run a dry run to see what changes would be made:

```bash
bundle exec rake fix:fix_scores_dry_run
```

## Step 4: Apply Score Fixes (if needed)
If the dry run shows fixes are needed, apply them:

```bash
# First, create a backup of current scores
bundle exec rake fix:backup_scores

# Then apply the fixes (this will ask for confirmation)
bundle exec rake fix:fix_scores
```

## Step 5: Verify Fixes
After applying fixes, verify they worked:

```bash
bundle exec rake verification:verify_scores
```

## Step 6: Production Deployment Process

### Option A: Deploy with Score Fixes (Recommended)
If you found score discrepancies in development:

1. **Deploy your code changes to production**
2. **Run verification script on production**:
   ```bash
   # On production server
   RAILS_ENV=production bundle exec rake verification:verify_scores
   ```
3. **If errors are found, run the fix script**:
   ```bash
   # First backup
   RAILS_ENV=production bundle exec rake fix:backup_scores
   
   # Then fix (will ask for confirmation)
   RAILS_ENV=production bundle exec rake fix:fix_scores
   ```
4. **Verify fixes worked**:
   ```bash
   RAILS_ENV=production bundle exec rake verification:verify_scores
   ```

### Option B: Deploy Without Score Fixes
If your development environment shows no score errors:

1. **Deploy your code changes to production**
2. **Run verification script on production**:
   ```bash
   RAILS_ENV=production bundle exec rake verification:verify_scores
   ```
3. **If errors are found, follow Option A steps 3-4**

## Available Rake Tasks

### Verification Tasks
- `rake verification:verify_scores` - Verify all user scores are correct
- `rake verification:verify_leaderboards` - Verify leaderboard calculations
- `rake 'verification:user_breakdown[username]'` - Detailed breakdown for specific user

### Fix Tasks
- `rake fix:fix_scores_dry_run` - Show what fixes would be made (no changes)
- `rake fix:fix_scores` - Apply score fixes (requires confirmation)
- `rake fix:backup_scores` - Backup current scores to JSON file

## Understanding Your Score System

### Weekly Scores
- **Game A (Preference Picks)**: Points equal to `pref_pick_int` when correct
- **Game B (Spread Picks)**: 7 points when correct, or 7 points for push (tie)
- **Weekly Total**: Game A + Game B points

### Cumulative Scores
- **Cumulative**: Running total of all points earned across all weeks

### Score Calculation Logic
1. Only games marked as `has_game_been_scored = true` count toward scores
2. Points are awarded based on `correct_pref_pick` and `correct_spread_pick` flags
3. Tie games award both Game A and Game B points

## Troubleshooting

### If Verification Shows Errors
1. Check if games are properly marked as scored (`has_game_been_scored = true`)
2. Verify selection flags (`correct_pref_pick`, `correct_spread_pick`) are set correctly
3. Ensure `pref_pick_int` values are correct for Game A scoring

### If Leaderboards Don't Match
The leaderboard methods in `User` model should match individual user scores:
- `User.weekly_points` - Top 5 weekly scores
- `User.cumulative_points` - Top 5 cumulative scores
- `User.full_weekly_points` - All weekly scores
- `User.full_cumulative_points` - All cumulative scores

## Safety Notes

1. **Always backup before making changes**
2. **Test in development first**
3. **Run dry runs before applying fixes**
4. **Verify fixes after applying them**
5. **Keep backups for at least 30 days**

## Emergency Rollback

If something goes wrong after deployment:

1. **Restore database backup**:
   ```bash
   psql your_production_db < production_backup_TIMESTAMP.sql
   ```

2. **Revert code deployment** (if needed)

3. **Re-run verification** to confirm rollback worked

## Contact Information

If you encounter issues not covered in this guide, review the application logs and consider:
- Checking database integrity
- Verifying game scoring logic in `app/models/game.rb`
- Reviewing user score calculation methods in `app/models/user.rb`
