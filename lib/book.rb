# frozen_string_literal: true

# card game book class
class Book
  attr_reader :cards

  def initialize(cards)
    @cards = cards
  end

  def rank
    @rank ||= cards.first.value
  end
end
