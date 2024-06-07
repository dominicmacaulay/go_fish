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

  describe '#remove_cards' do
    before do
      @card1 = MockCard.new('2', 'Hearts')
      @card2 = MockCard.new('5', 'Hearts')
      player.add_to_hand([@card1, @card2])
    end
    it "removes given card from the player's hand" do
      player.remove_cards('2')
      expect(player.hand).to include @card2
      expect(player.hand).not_to include @card1
    end
    it 'removes mulitple cards' do
      card3 = MockCard.new('2', 'Spades')
      player.remove_cards('2')
      expect(player.hand).to include @card2
      expect(player.hand).not_to include @card1
      expect(player.hand).not_to include card3
    end
    it 'returns an array of the cards it removed' do
      card3 = MockCard.new('2', 'Spades')
      received_cards = player.remove_cards('2')
      expect(received_cards).to include @card1
      expect(received_cards).to include card3
    end
  end

  describe '#hand_has_rank?' do
    before do
      card1 = MockCard.new('2', 'Hearts')
      card2 = MockCard.new('2', 'Spades')
      card3 = MockCard.new('4', 'Spades')
      player.add_to_hand([card1, card2, card3])
    end
    it 'returns true if the player has any cards with the given rank in hand' do
      expect(player.hand_has_rank?('2')).to be true
      expect(player.hand_has_rank?('4')).to be true
    end
    it 'returns false if the player does not have any cards with the given rank in hand' do
      expect(player.hand_has_rank?('3')).to be false
    end
  end
end
