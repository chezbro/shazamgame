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

  # def fav_or_dog(game)
  #   if game.spread > 0
  #     return "FAV:"
  #   elsif game.spread == 0
  #     return "Even:"
  #   else
  #     return "DOG:"
  #   end
  # end
  
end
