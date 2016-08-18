class Selection < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  validates_presence_of :user_id
  validates_presence_of :game_id
  validates_presence_of :pref_pick_int
  validates_presence_of :pref_pick_team
  validates_presence_of :spread_pick_team
  

  def user_pref_pick_uniqueness(selections)
    selections.each do |selection|
      if selection.pref_pick_int.present?
      else
      end
    end
  end


  # def self.pref_picks(user)
  #   arr = []
  #   user.selections.each do |selection|
  #     if selection.game.week.id == Week.last.id
  #       arr << selection.game.pref_pick_int
  #     end
  #   end
  #   arr
  # end

end