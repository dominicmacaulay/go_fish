# frozen_string_literal: true

require_relative '../lib/player'
require_relative '../lib/card'
require 'spec_helper'

# test the player class
RSpec.describe Player do
  let(:player) { Player.new(name: 'A Mysterious Figure') }
  describe '#initialize' do
    it 'starts with the given name' do
      expect(player.name).to eql 'A Mysterious Figure'
    end
    it 'starts with an empty books array' do
      expect(player.books).to be_empty
    end
    it 'starts with an empty hand' do
      expect(player.hand).to be_empty
    end
  end

  describe '#add_to_hand' do
    it "adds the given card to the player's hand" do
      card = Card.new(rank: '2', suit: 'Hearts')
      player.add_to_hand(card)
      expect(player.hand).to include card
    end
    it "can add mutliple cards to the player's hand" do
      card1 = Card.new(rank: '2', suit: 'Hearts')
      card2 = Card.new(rank: '2', suit: 'Spades')
      cards = [card1, card2]
      player.add_to_hand(cards)
      expect(player.hand).to include card1
      expect(player.hand).to include card2
    end
  end

  describe '#remove_by_rank' do
    before do
      @card1 = Card.new(rank: '2', suit: 'Hearts')
      @card2 = Card.new(rank: '5', suit: 'Hearts')
      player.add_to_hand([@card1, @card2])
    end
    it "removes given card from the player's hand" do
      player.remove_by_rank('2')
      expect(player.hand).to include @card2
      expect(player.hand).not_to include @card1
    end
    it 'removes mulitple cards' do
      card3 = Card.new(rank: '2', suit: 'Spades')
      player.add_to_hand(card3)
      player.remove_by_rank('2')
      expect(player.hand).to include @card2
      expect(player.hand).not_to include @card1
      expect(player.hand).not_to include card3
    end
    it 'returns an array of the cards it removed' do
      card3 = Card.new(rank: '2', suit: 'Spades')
      player.add_to_hand(card3)
      received_cards = player.remove_by_rank('2')
      expect(received_cards).to include @card1
      expect(received_cards).to include card3
    end
  end

  describe '#hand_has_rank?' do
    before do
      card1 = Card.new(rank: '2', suit: 'Hearts')
      card2 = Card.new(rank: '2', suit: 'Spades')
      card3 = Card.new(rank: '4', suit: 'Spades')
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
