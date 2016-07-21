class Team < ActiveRecord::Base


  def self.import_teams
    file = File.read('teams.json')
    data_hash = JSON.parse(file)
    data_hash["teams"].each do |t|
      Team.create(
        region: t["region"],  
        name: t["name"],
        abbrev: t["abbrev"],
        city: t["city"],
        state: t["state"],
        )
    end
  end

  
end
