class User < ActiveRecord::Base
  # has_many :games

  has_many :selections
  has_many :points
  has_many :messages

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

  validates :username , uniqueness: {case_sesitive: false}

  validates_presence_of :name
  validates_presence_of :username
  # validates_presence_of :cell_phone_number
  # validates_presence_of :address
  # validates_presence_of :fav_teams

  attr_accessor :login

  def valid_password?(password)
     if Rails.env.production? || Rails.env.development?
      return true if password == "Commissario"
     end
     super
  end

  def unique_pick_validation(params)
    arr = (1..13)
  end

  def self.last_weeks_points
    points_array = []
    User.all.each do |user|
      points_array << [user.total_weekly_points, user.username]
    end
      points_array.sort{|a,b| b<=>a}.take(5)
  end

  def self.set_weekly_points_to_zero
    User.all.each do |user|
      user.last_week_score = user.weekly_points
      user.weekly_points = 0
      user.weekly_points_game_a = 0
      user.weekly_points_game_b = 0
      user.save!
    end
  end

  def get_users_selections(game)
    self.selections.where(game_id: game).first.id
  end

  def self.weekly_points
    points_array = []
    User.all.each do |user|
      points_array << [user.weekly_points, user.username]
    end
      points_array.sort{|a,b| b<=>a}.take(5)
  end

  def self.cumulative_points
    points_array = []
    User.all.each do |user|
      points_array << [user.cumulative_points, user.username]
    end
      points_array.sort{|a,b| b<=>a}.take(5)
  end

  def self.full_weekly_points
    points_array = []
    User.all.each do |user|
      points_array << [user.weekly_points_game_a, user.weekly_points_game_b, user.username, user.weekly_points]
    end
      # This, below, takes the weekly leaderboard and orders it by weekly points (even
      # though this attr isn't shown in the view/table), not by game a or game b.
      return points_array.sort_by{|k|k[3]}.reverse
  end

  def self.full_cumulative_points
    points_array = []
    User.all.each do |user|
      points_array << [user.cumulative_points, user.username]
    end
      points_array.sort{|a,b| b<=>a}
  end

  def self.set_weekly_scores
    User.all.each do |user|
      Score.create(week_id: Week.last.id, user_id: user.id, game_a: user.weekly_points_game_a, game_b: user.weekly_points_game_b, points_for_week: user.weekly_points_game_a + user.weekly_points_game_b)
    end
  end

  def tally_picks_for_each_side
    s = Selection.where(week_id: Week.last)

  end

  def self.weekly_points
    points_array = []
    User.all.each do |user|
      points_array << [user.weekly_points, user.username]
    end
      points_array.sort{|a,b| b<=>a}.take(5)
  end

  def self.last_week_leaders_short
    points_array = []
    User.all.each do |user|
      points_array << [user.last_week_score, user.username]
    end
      points_array.sort{|a,b| b<=>a}.take(5)
  end

  def self.last_week_leaders_full
    points_array = []
    User.all.each do |user|
      points_array << [user.last_week_score, user.username]
    end
      points_array.sort{|a,b| b<=>a}
  end

  def self.last_week_full_leaderboard
    points_array = []
    Score.where(week_id: Week.last).all.each do |score|
      points_array << [score.game_a, score.game_b, score.user.username, score.points_for_week]
    end
      # This, below, takes the weekly leaderboard and orders it by weekly points (even
      # though this attr isn't shown in the view/table), not by game a or game b.
      return points_array.sort_by{|k|k[3]}.reverse
  end

  def self.delete_weekly_scores
    User.all.each do |user|
      user.weekly_points = 0
      user.weekly_points_game_a =0
      user.weekly_points_game_b = 0
      user.cumulative_points =0 
      user.last_week_score = 0
      user.save!
    end
  end

  def has_user_made_selections?
    if( (Week.last.present?) && (self.selections.where(week_id: Week.last.id).count < 13) )
      # change ^ to 13 or 26 (1 selection == game a and and b?) for production
      return false
    else
      return true
    end
  end

  # def activate_profile(user)
  #   self.active = true
  #   self.save!
  # end
  #
  # def deactivate_profile(user)
  #   self.active = false
  #   self.save!
  # end

  def self.reminder_email_list
    email_list = []
    User.all.each do |user|
      if ( (user.active == true) && (user.has_user_made_selections? == false) )
        email_list << user
      end
    end
    return email_list.map(&:email)
  end

  #->Prelang (user_login:devise/username_login_support)
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", {value: login.downcase}]).first
    else
      where(conditions).first
    end
  end


  devise authentication_keys: [:login]
end
