# frozen_string_literal: true

require_relative '../lib/deck'
require 'spec_helper'

# test the deck class
RSpec.describe Deck do
  describe '#initialize' do
    it 'creates a deck of 52 cards by default' do
      deck = described_class.new
      expect(deck.cards.length).to eql 52
    end
    it 'creates a deck of 104 cards when I indicate I want 2 stacks' do
      deck = described_class.new(stack_number: 2)
      expect(deck.cards.length).to eql 104
    end
  end

  describe '#deal' do
    before do
      @deck = described_class.new
      @top_card = @deck.cards[0]
    end
    it 'returns one card from its cards array' do
      expect(@deck.deal).to equal @top_card
    end
    it 'deals unique cards' do
      @deck.deal
      new_card = @deck.deal
      expect(new_card).not_to equal @top_card
    end
  end

  describe '#shuffle' do
    it "shuffles the deck's cards" do
      deck1 = described_class.new
      deck2 = described_class.new
      deck1.shuffle(Random.new(1000))
      expect(deck1.cards).not_to eql(deck2.cards)
    end
  end
end
