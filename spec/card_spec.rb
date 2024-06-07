# frozen_string_literal: true

require_relative '../lib/card'
require_relative 'spec_helper'

# test the card functionality
RSpec.describe Card do # rubocop:disable Metrics/BlockLength
  describe 'attributes' do
    before do
      @card = described_class.new('4', 'Hearts')
    end
    it 'should include the given rank' do
      expect(@card.rank).to eql '4'
    end
    it 'should include the given suit' do
      expect(@card.suit).to eql 'Hearts'
    end
    it 'should include the given numerical_value' do
      expect(@card.numerical_value).to eql 2
    end
  end

  describe '#==' do
    before do
      @card1 = described_class.new('4', 'Hearts')
      @card2 = described_class.new('4', 'Spades')
      @card3 = described_class.new('5', 'Hearts')
    end
    it 'returns true if the ranks are equal' do
      expect(@card1).to eq @card2
    end
    it 'returns false if the ranks are not equal' do
      expect(@card1).not_to eq @card3
    end
  end
end
