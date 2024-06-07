require_relative 'player'
require_relative 'deck'

# go fish game class
class Game
  attr_reader :players

  def initialize(players)
    @players = players
  end
end
