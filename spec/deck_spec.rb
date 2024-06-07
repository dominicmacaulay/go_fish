# frozen_string_literal: true

require_relative '../lib/deck'
require_relative 'spec_helper'

# test the deck class
RSpec.describe Deck do
  describe '#initialize' do
    it 'creates a deck of 52 cards by default' do
      deck = described_class.new
      expect(deck.cards.length).to eql 52
    end
    it 'creates a deck of 64 cards when I indicate I want 2 stacks' do
      deck = described_class.new(2)
      expect(deck.cards.length).to eql 104
    end
  end
end
