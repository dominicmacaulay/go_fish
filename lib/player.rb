# card game player class
class Player
  attr_accessor :name, :books, :hand

  def initialize(name = 'A Mysterious Figure')
    @name = name
    @books = []
    @hand = []
  end

  def add_to_hand(cards)
    hand.push(*cards)
  end
end
