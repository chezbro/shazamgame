class User < ActiveRecord::Base
    # has_many :games

  has_many :selections

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
  
  validates :username , uniqueness: {case_sesitive: false}

  attr_accessor :login

  def get_users_selections(game)
    self.selections.where(game_id: game).first.id
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
