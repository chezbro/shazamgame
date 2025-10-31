class Selection < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  belongs_to :week

  validates_presence_of :user_id
  validates_presence_of :game_id
  validates_presence_of :pref_pick_int
  validates_presence_of :pref_pick_team
  validates_presence_of :spread_pick_team
  validates :user, presence: true
  validate :pref_pick_int_unique_within_week

  def self.ransackable_attributes(auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(auth_object = nil)
    authorizable_ransackable_associations
  end
  
  private

  def pref_pick_int_unique_within_week
    return unless user_id && game_id && pref_pick_int
    
    game = Game.find_by(id: game_id)
    return unless game
    
    # Bowl games allow duplicate pref pick values (you can use each ranking 1-13 twice)
    return if game.week&.bowl_game?
    
    # Check if another selection exists for this user in the same week with the same pref_pick_int
    existing_selection = Selection
      .joins(:game)
      .where(user_id: user_id)
      .where(games: { week_id: game.week_id })
      .where(pref_pick_int: pref_pick_int)
      .where.not(id: id) # Exclude current selection when updating
      .exists?
    
    if existing_selection
      errors.add(:pref_pick_int, "must be unique. You have already used #{pref_pick_int} for another game this week.")
    end
  end

end
