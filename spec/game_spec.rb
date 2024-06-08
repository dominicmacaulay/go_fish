# frozen_string_literal: true

require_relative '../lib/player'
require_relative '../lib/game'
require_relative '../lib/card'
require 'spec_helper'

# test go fish game
RSpec.describe Game do
  let(:player1) { Player.new(name: 'P 1') }
  let(:player2) { Player.new(name: 'P 2') }
  let(:game) { Game.new([player1, player2]) }
  describe '#initialize' do
    it 'add the given players' do
      expect(game.players).to include player1
      expect(game.players).to include player2
    end
    it 'makes a new deck when called' do
      expect(game.deck.cards.count).to eql 52
    end
  end

  describe '#start' do
    it 'shuffles the deck' do
      expect(game.deck).to receive(:shuffle).once
      game.start
    end
    it 'deals 5 cards to each player' do
      game.start
      expect(game.players.first.hand.length).to eql 5
      expect(game.players.last.hand.length).to eql 5
    end
  end

  describe 'player_has_rank?' do
    before do
      player1.add_to_hand([Card.new(rank: '4', suit: 'Hearts'), Card.new(rank: '8', suit: 'Spades')])
    end
    it 'returns true when the player has the card' do
      expect(game.player_has_rank?(player1, '4')).to be true
      expect(game.player_has_rank?(player1, '8')).to be true
    end
    it 'returns false when the player does not have the card' do
      expect(game.player_has_rank?(player1, '6')).to be false
      expect(game.player_has_rank?(player1, 'Ace')).to be false
    end
  end

  describe 'play_round' do
  end
end
