# frozen_string_literal: true

# playing card
class Card
  attr_reader :rank, :suit, :numerical_value

  def initialize(rank, suit, number)
    @rank = rank
    @suit = suit
    @numerical_value = number
  end

  def ==(other)
    other.rank == rank
  end
end
