# frozen_string_literal: true

require_relative 'card'

# deck class for a card game
class Deck
  attr_reader :cards, :stack_number

  def initialize(stack_number = 1, cards = nil)
    @stack_number = stack_number
    @cards = cards.nil? ? create_deck : cards
  end

  def create_deck
    cards = []
    stack_number.times do
      cards.push(*retrieve_one_deck)
    end
    cards
  end

  def retrieve_one_deck
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank, suit)
      end
    end
  end
end
