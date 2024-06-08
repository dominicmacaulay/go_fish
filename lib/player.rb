# frozen_string_literal: true

# card game player class
class Player
  attr_accessor :name, :books, :hand

  def initialize(name:, hand: [], books: [])
    @name = name
    @books = books
    @hand = hand
  end

  def add_to_hand(cards)
    hand.push(*cards)
  end

  def remove_by_rank(rank)
    hand.map do |card|
      hand.delete(card) if card.rank == rank
    end
  end

  def hand_has_rank?(given_rank)
    hand.select { |card| card.rank == given_rank }.count.positive?
  end

  def rank_count(given_rank)
    hand.select { |card| card.rank == given_rank }.count
  end
end
