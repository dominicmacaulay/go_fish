# frozen_string_literal: true

require_relative 'card'

# deck class for a card game
class Deck
  attr_reader :stack_number
  attr_accessor :cards

  def initialize(stack_number: 1, cards: nil)
    @stack_number = stack_number
    @cards = cards.nil? ? create_deck : cards
  end

  def deal
    @cards.shift
  end

  def shuffle(seed = Random.new)
    cards.shuffle!(random: seed)
  end

  def clear_cards
    self.cards = []
  end

  private

  def create_deck
    stack_number.times.flat_map { retrieve_one_deck }
  end

  def retrieve_one_deck
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank: rank, suit: suit)
      end
    end
  end
end
