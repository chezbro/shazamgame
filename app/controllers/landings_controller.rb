class LandingsController < ApplicationController
  before_action :check_if_admin, only: [:users]

  def index
  end

  def email_reminders_page
    @email_list = User.reminder_email_list
  end

  def send_reminder_email
    @email_list = UserMailer.selections_reminder_email
    @email_list.deliver!
  end

  def activity
    @last_week_points = User.last_week_leaders_short
    @weekly_points = User.weekly_points
    @cumulative_points = User.cumulative_points
    @week = Week.last
    @total_selections_for_pref_pick_team = Game.total_selections_for_pref_pick_team.sort_by {|a,b| b}.reverse
    # @total_selections_for_spread_pick_team = Game.total_selections_for_spread_pick_team

  end

  def stats
    @full_cumulative_points = User.full_cumulative_points
    @full_weekly_points = User.full_weekly_points
  end

  def fav_team
  end


  def last_week_leaders
    @last_week_leaders = User.last_week_leaders_full
  end

  def users
  end

  def player_selections
    # Find the active week(s)
    @week = Week.where(active: true).first
    
    if @week.nil?
      # Fallback to last week if no active week
      @week = Week.last
    end
    
    # Get all weeks
    @all_weeks = Week.all.order(created_at: :desc)
    
    # Get games for this week
    @games = Game.where(week_id: @week.id).where(game_selected_by_admin: true) if @week
    
    # Add logging to help debug
    Rails.logger.info "Week: #{@week.inspect}"
    Rails.logger.info "Games count: #{@games&.count}"
    Rails.logger.info "All weeks count: #{@all_weeks&.count}"
  end

  def team_selections
    @games = Game.where(week_id: Week.last)
  end

  def instructions
  end

  def real_time_scores
  end

  protected

  def check_if_admin
    if current_user.admin == true
      # allow thru
    else
      redirect_to root_path
    end
  end

end
