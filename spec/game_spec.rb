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
      expect(game.player_has_rank?(player2, '4')).to be false
    end
  end

  describe 'play_round' do
    before do
      player1.add_to_hand([Card.new(rank: '4', suit: 'Hearts'), Card.new(rank: '8', suit: 'Spades')])
      player2.add_to_hand([Card.new(rank: '4', suit: 'Hearts'), Card.new(rank: '9', suit: 'Spades')])
    end
    it 'runs transaction and returns message if the asked player has the card' do
      message = 'P 1 took one 4 from P 2.'
      expect(game.play_round(this_player: player1, other_player: player2, rank: '4')).to eql message
      expect(player1.hand.select { |card| card.rank == '4' }.count).to be 2
      expect(player2.hand.select { |card| card.rank == '4' }.count).to be 0
    end
    it 'runs transaction and returns message if the asked player has multiple cards' do
      message = "P 1 took two 4's from P 2."
      player2.add_to_hand(Card.new(rank: '4', suit: 'Spades'))
      expect(game.play_round(this_player: player1, other_player: player2, rank: '4')).to eql message
      expect(player1.hand.select { |card| card.rank == '4' }.count).to be 3
      expect(player2.hand.select { |card| card.rank == '4' }.count).to be 0
    end
    it 'returns Go Fish and draws from the pile if the other player doesn not have the rank' do
      message = 'Go Fish! You took a Jack of Hearts from the pond.'
      game = Game.new([player1, player2], [Card.new(rank: 'Jack', suit: 'Hearts')])
      expect(game.play_round(this_player: player1, other_player: player2, rank: '8')).to eql message
    end
  end
end
