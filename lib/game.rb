# frozen_string_literal: true

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

  def player_has_rank?(player, rank)
    player.hand_has_rank?(rank)
  end

  def play_round(this_player:, other_player:, rank:)
    receive_card_from_player(this_player, other_player, rank) if other_player.hand_has_rank?(rank)
  end

  private

  def receive_card_from_player(this_player, other_player, rank)
    cards = other_player.remove_by_rank(rank)
    this_player.add_to_hand(cards)
    if cards.count == 1
      "#{this_player.name} took one #{rank} from #{other_player.name}"
    else
      "#{this_player.name} took #{integer_to_string(cards.count)} #{rank}'s from #{other_player.name}"
    end
  end

  def integer_to_string(integer)
    if integer == 2
      'two'
    elsif integer == 3
      'three'
    else
      'several'
    end
  end
end
