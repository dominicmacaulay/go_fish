# frozen_string_literal: true

# playing card
class Card
  attr_reader :rank, :suit

  RANKS = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace].freeze
  SUITS = %w[Spades Clubs Hearts Diamonds].freeze

  def initialize(rank:, suit:)
    @rank = rank
    @suit = suit
  end

  def value
    @value ||= RANKS.index(rank) + 1
  end

  # possibly convert this to the original version and make a rank? method
  # which would carry out this comparison
  def ==(other)
    other.rank == rank && other.suit == suit
  end
end
