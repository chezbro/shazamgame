class LandingsController < ApplicationController
  before_filter :check_if_admin, only: [:users]

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
    @weekly_points = User.weekly_points
    @cumulative_points = User.cumulative_points
    @week = Week.last
  end

  def stats
    @full_cumulative_points = User.full_cumulative_points
    @full_weekly_points = User.full_weekly_points
    @user_count = Array.new(User.all.count) {|i| i+1 }
  end

  def last_week_leaders
    @last_week_leaders = User.last_week_leaders
  end

  def users
  end

  def player_selections
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
