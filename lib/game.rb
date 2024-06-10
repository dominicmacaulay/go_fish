# frozen_string_literal: true

require_relative 'player'
require_relative 'deck'

# go fish game class
class Game
  attr_reader :players, :deck_cards
  attr_accessor :current_player

  def initialize(players, deck_cards = nil)
    @players = players
    @deck_cards = deck_cards
    @current_player = @players.first
  end

  def deck
    @deck ||= Deck.new(cards: deck_cards)
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

  def play_round(other_player:, rank:)
    player_rank_count = current_player.rank_count(rank).dup
    message = execute_transaction(current_player, other_player, rank)
    switch_player if player_gained_rank?(current_player, rank, player_rank_count)
    current_player.make_book_if_possible
    message
  end

  def determine_winner
    book_count = players.map(&:book_count)
    if book_count == 13
        
    end
  end

  private

  def switch_player
    current_index = players.index(current_player)
    self.current_player = players[next_index(current_index)]
  end

  def next_index(index)
    if index == players.index(players.last)
      0
    else
      index + 1
    end

  end

  def player_gained_rank?(player, rank, count)
    new_count = player.rank_count(rank)
    new_count == count
  end

  def execute_transaction(this_player, other_player, rank)
    if other_player.hand_has_rank?(rank)
      receive_card_from_player(this_player, other_player, rank)
    else
      receive_card_from_pond(this_player)
    end
  end

  def receive_card_from_pond(player)
    card = deck.deal
    player.add_to_hand(card)
    "Go Fish! You took a #{card.rank} of #{card.suit} from the pond."
  end

  def receive_card_from_player(this_player, other_player, rank)
    cards = other_player.remove_by_rank(rank)
    this_player.add_to_hand(cards)
    if cards.count == 1
      "#{this_player.name} took one #{rank} from #{other_player.name}."
    else
      "#{this_player.name} took #{integer_to_string(cards.count)} #{rank}'s from #{other_player.name}."
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
