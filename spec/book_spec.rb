# frozen_string_literal: true

require_relative '../lib/book'
require_relative '../lib/card'
require 'spec_helper'

# test the book class
RSpec.describe Book do
  describe '#initialize' do
    before do
      @card1 = Card.new(rank: '4', suit: 'Diamonds')
      @card2 = Card.new(rank: '4', suit: 'Hearts')
      @card3 = Card.new(rank: '4', suit: 'Clubs')
      @card4 = Card.new(rank: '4', suit: 'Spades')
      @cards = [@card1, @card2, @card3, @card4]
      @book = Book.new(@cards)
    end
    it 'should contain the cards given to it at creation' do
      expect(@book.cards).to include(@card1)
      expect(@book.cards).to include(@card2)
      expect(@book.cards).to include(@card3)
      expect(@book.cards).to include(@card4)
    end
    it 'should have the numerical value of the cards' do
      expect(@book.rank).to be 2
    end
  end
end
