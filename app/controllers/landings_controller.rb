class LandingsController < ApplicationController
  # before_filter :disable_navbar, only: [:index]

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
  end

  def users
  end


  def instructions
  end

  def real_time_scores
  end

end
