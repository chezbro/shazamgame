class Team < ActiveRecord::Base
  has_many :games

  def self.import_teams
    file = File.read('teams.json')
    data_hash = JSON.parse(file)
    data_hash["teams"].each do |t|
      Team.find_or_create_by(region: t["region"], name: t["name"]) do |team|
        team.abbrev = t["abbrev"]
        team.city = t["city"]
        team.state = t["state"]
      end
    end
  end


end
