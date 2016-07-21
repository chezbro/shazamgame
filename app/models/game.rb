class Game < ActiveRecord::Base
  belongs_to :week
  # belongs_to :user

  belongs_to :away_team, class_name: 'Team', foreign_key: 'away_team_id'
  belongs_to :home_team, class_name: 'Team', foreign_key: 'home_team_id'
  
  has_many :selections
  has_many :users
  



  def teams
    [away_team, home_team]
  end


end
