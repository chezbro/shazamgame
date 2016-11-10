desc "Disable Selections "

task :disable_selections => :environment do
  Game.disable_picks
end