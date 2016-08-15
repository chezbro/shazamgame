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


end
