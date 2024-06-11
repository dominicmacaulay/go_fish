# frozen_string_literal: false

require_relative 'book'

# card game player class
class Player
  attr_accessor :books, :hand
  attr_reader :name

  def initialize(name:, hand: [], books: [])
    @name = name
    @books = books
    @hand = hand
  end

  def book_count
    books.count
  end

  def hand_count
    hand.count
  end

  def total_book_value
    total_value = 0
    books.each { |book| total_value += book.rank }
    total_value
  end

  def add_to_hand(cards)
    hand.push(*cards)
  end

  def remove_by_rank(rank)
    cards = hand.map do |card|
      hand.delete(card) if card.rank == rank
    end
    cards.compact
  end

  def hand_has_rank?(given_rank)
    hand.select { |card| card.rank == given_rank }.count.positive?
  end

  def rank_count(given_rank)
    hand.select { |card| card.rank == given_rank }.count
  end

  def make_book_if_possible # rubocop:disable Metrics/AbcSize
    hand.dup.each do |card|
      next unless rank_count(card.rank) >= 4

      cards = hand.select { |other_card| card.rank == other_card.rank }
      hand.delete_if { |other_card| card.rank == other_card.rank }
      books.push(Book.new(cards))
    end
  end

  def display_hand
    message = 'You have '
    hand.each do |card|
      message.concat('and ') if card == hand.last
      message.concat("a #{card.rank} of #{card.suit}")
      message.concat(', ') unless card == hand.last
    end
    message
  end
end
