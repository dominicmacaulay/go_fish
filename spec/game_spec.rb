# frozen_string_literal: true

require_relative '../lib/player'
require_relative '../lib/game'
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
  end

  describe '#start' do
    it 'makes a new deck' do
      expect(game.deck.cards.count).to eql 52
    end
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

  describe 'play_round' do
  end
end
