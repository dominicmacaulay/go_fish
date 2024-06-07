# frozen_string_literal: true

require_relative '../lib/player'
require 'spec_helper'

class MockCard
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

# test the player class
RSpec.describe Player do
  let(:player) { Player.new }
  describe '#initialize' do
    it 'starts with a name by default' do
      expect(player.name).to eql 'A Mysterious Figure'
    end
    it 'starts with an empty books array' do
      expect(player.books.empty?).to be true
    end
    it 'starts with an empty hand' do
      expect(player.hand.empty?).to be true
    end
  end

  describe '#add_to_hand' do
    it "adds the given card to the player's hand" do
      card = MockCard.new('2', 'Hearts')
      player.add_to_hand(card)
      expect(player.hand).to include card
    end
    it "can add mutliple cards to the player's hand" do
      card1 = MockCard.new('2', 'Hearts')
      card2 = MockCard.new('2', 'Spades')
      cards = [card1, card2]
      player.add_to_hand(cards)
      expect(player.hand).to include card1
      expect(player.hand).to include card2
    end
  end
end