class User < ActiveRecord::Base
    # has_many :games

  has_many :selections
  has_many :scores

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
  
  validates :username , uniqueness: {case_sesitive: false}

  validates_presence_of :name
  validates_presence_of :username
  # validates_presence_of :cell_phone_number
  # validates_presence_of :address
  # validates_presence_of :fav_teams


  attr_accessor :login
  
  def unique_pick_validation(params)
    arr = (1..13)    
  end

  
  def self.set_weekly_points_to_zero
    User.all.each do |user|
      user.weekly_points = 0
      user.weekly_points_game_a = 0
      user.weekly_points_game_b = 0
      user.save!
    end
  end

#   def pref_picks
#   arr = []
#   selections.where(week_id: Week.last).each do |us|
#     arr << us.pref_pick_int
#     arr
#   end
# end
  
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
      points_array << [user.weekly_points_game_a, user.weekly_points_game_b, user.username]
    end
      points_array.sort {|x, y| x.to_s<=>y.to_s}
  end

  def self.full_cumulative_points
    points_array = []
    User.all.each do |user|
      points_array << [user.cumulative_points, user.username]
    end
      points_array.sort{|a,b| b<=>a}
  end


  def self.delete_weekly_scores
    User.all.each do |user|
      user.weekly_points.delete
    end
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
