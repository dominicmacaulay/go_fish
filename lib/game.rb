require_relative 'player'
require_relative 'deck'

# go fish game class
class Game
  attr_reader :players

  def initialize(players)
    @players = players
  end

  def deck
    @deck ||= Deck.new
  end

  def start
    deck.shuffle
    5.times do
      players.each { |player| player.add_to_hand(deck.deal) }
    end
  end
end
