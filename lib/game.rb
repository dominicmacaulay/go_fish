# frozen_string_literal: false

require_relative 'player'
require_relative 'deck'

# go fish game class
class Game
  attr_reader :players, :deck_cards
  attr_accessor :current_player, :winners

  def initialize(players, deck_cards = nil)
    @players = players
    @deck_cards = deck_cards
    @current_player = @players.first
    @winners = nil
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
    return unless current_player.hand_count.zero?

    if deck.cards.empty?
      switch_player
      return 'Sorry, the pool is empty. You are going to have to wait this one out.'
    end
    5.times { current_player.add_to_hand(deck.deal) unless deck.cards.empty? }
    'You took cards from the pond since their hand was empty.'
  end

  def match_player_to_name(name)
    return 'You cannot enter your own name! Try again: ' if name == current_player.name

    players.each do |player|
      return player if player.name == name
    end
    "You must enter a valid player's name. Try again: "
  end

  def player_has_rank?(rank)
    current_player.hand_has_rank?(rank)
  end

  def play_round(other_player:, rank:)
    player_rank_count = current_player.rank_count(rank).dup
    message = execute_transaction(other_player, rank)
    player_gained = player_gained_rank?(rank, player_rank_count)
    message.concat(" And created a book of #{rank}'s.") if current_player.make_book_if_possible == true
    switch_player unless player_gained
    check_for_winners
    message
  end

  def display_winners
    winners.count > 1 ? tie_message_for_multiple_winners(winners) : single_winner_message(winners.first)
  end

  def check_for_winners
    return unless players.map(&:hand_count).sum.zero? && deck.cards.empty?

    self.winners = determine_winners
  end

  private

  def single_winner_message(winner)
    "#{winner.name} won the game with #{winner.book_count} books totalling in #{winner.total_book_value}"
  end

  def tie_message_for_multiple_winners(winners)
    message = ''
    winners.each do |winner|
      message.concat('and ') if winner == winners.last
      message.concat("#{winner.name} ")
      message.concat(', ') if winner != winners.last && winner != winners[-2]
    end
    message.concat("tied with #{winners.first.book_count} books totalling in #{winners.first.total_book_value}")
  end

  def determine_winners
    possible_winners = players_with_highest_book_count
    player_with_highest_book_value(possible_winners)
  end

  def player_with_highest_book_value(players)
    maximum_value = 0
    players.each do |player|
      maximum_value = player.total_book_value if player.total_book_value > maximum_value
    end
    players.select { |player| player.total_book_value == maximum_value }
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
    elsif deck.cards.empty?
      'Go Fish! Sorry, there are no fish in the pond (The draw pile is empty).'
    else
      receive_card_from_pond
    end
  end

  def receive_card_from_pond
    card = deck.deal
    current_player.add_to_hand(card)
    "Go Fish! #{current_player.name} took a #{card.rank} of #{card.suit} from the pond."
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
