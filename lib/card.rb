# frozen_string_literal: true

# playing card
class Card
  attr_reader :rank, :suit, :numerical_value

  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[S C H D].freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @numerical_value = RANKS.index(rank)
  end

  def ==(other)
    other.rank == rank
  end
end
