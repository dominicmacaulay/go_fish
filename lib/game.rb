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

  def deal_to_player_if_necessary
    current_player.add_to_hand(deck.deal) if current_player.hand_count.zero?
  end

  def player_has_rank?(rank)
    current_player.hand_has_rank?(rank)
  end

  def play_round(other_player:, rank:)
    player_rank_count = current_player.rank_count(rank).dup
    message = execute_transaction(other_player, rank)
    player_gained = player_gained_rank?(rank, player_rank_count)
    current_player.make_book_if_possible
    switch_player unless player_gained
    message
  end

  def winner
    return nil unless players.map(&:hand_count).sum.zero? && deck.cards.empty?

    determine_winner
  end

  private

  def determine_winner
    possible_winners = players_with_highest_book_count
    player_with_highest_book_value(possible_winners)
  end

  def player_with_highest_book_value(players)
    maximum_value = 0
    players.each do |player|
      maximum_value = player.total_book_value if player.total_book_value > maximum_value
    end
    players.detect { |player| player.total_book_value == maximum_value }
  end

  def players_with_highest_book_count
    maximum_value = 0
    players.each do |player|
      maximum_value = player.book_count if player.book_count > maximum_value
    end
    players.select { |player| player.book_count == maximum_value }
  end

  def switch_player
    current_index = players.index(current_player)
    self.current_player = players[(current_index + 1) % players.count]
  end

  def player_gained_rank?(rank, count)
    new_count = current_player.rank_count(rank)
    new_count != count
  end

  def execute_transaction(other_player, rank)
    if other_player.hand_has_rank?(rank)
      receive_card_from_player(other_player, rank)
    else
      receive_card_from_pond
    end
  end

  def receive_card_from_pond
    card = deck.deal
    current_player.add_to_hand(card)
    "Go Fish! You took a #{card.rank} of #{card.suit} from the pond."
  end

  def receive_card_from_player(other_player, rank)
    cards = other_player.remove_by_rank(rank)
    current_player.add_to_hand(cards)
    if cards.count == 1
      "#{current_player.name} took one #{rank} from #{other_player.name}."
    else
      "#{current_player.name} took #{integer_to_string(cards.count)} #{rank}'s from #{other_player.name}."
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
