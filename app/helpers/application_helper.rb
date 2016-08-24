module ApplicationHelper

  def spread_operator(game)
    if game.spread > 0
      return "+"
    elsif game.spread == 0
      return " "
    else 
      return " "
    end
  end

  def week_amount
    Week.all.count.to_s
  end

  def check_existing_selection(game)
    if Selection.where(user_id: current_user).where(game_id: game.id).present?
      @selection = Selection.where(user_id: current_user).where(game_id: game.id).first 
    else
      @selection = Selection.new
    end
  end

  def check_existing_submit(game)
    if Selection.where(user_id: current_user).where(game_id: game.id).present?
      submit_msg = "Update Selection"
    else
      submit_msg = "New Selection"
    end
  end

  
end
