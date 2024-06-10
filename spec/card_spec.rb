# frozen_string_literal: true

require_relative '../lib/card'
require 'spec_helper'

# test the card functionality
RSpec.describe Card do
  describe 'attributes' do
    before do
      @card = described_class.new(rank: '4', suit: 'Hearts')
    end
    it 'should include the given rank' do
      expect(@card.rank).to eql '4'
    end
    it 'should include the given suit' do
      expect(@card.suit).to eql 'Hearts'
    end
    it 'should include the given value' do
      expect(@card.value).to eql 3
    end
  end

  describe '#==' do
    before do
      @card1 = described_class.new(rank: '4', suit: 'Hearts')
      @card2 = described_class.new(rank: '4', suit: 'Hearts')
      @card3 = described_class.new(rank: '4', suit: 'Spades')
      @card4 = described_class.new(rank: '5', suit: 'Spades')
    end
    it 'returns true if the ranks are equal' do
      expect(@card1).to eq @card2
    end
    it 'returns false if the ranks are not equal' do
      expect(@card1).not_to eq @card3
      expect(@card3).not_to eq @card4
    end
  end
end
