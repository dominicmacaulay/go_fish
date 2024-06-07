# card game player class
class Player
  attr_reader :name, :books, :hand

  def initialize(name = 'A Mysterious Figure')
    @name = name
    @books = []
    @hand = []
  end
end
