# frozen_string_literal: true

require_relative '../lib/player'
require_relative '../lib/game'
require 'spec_helper'

# test go fish game
RSpec.describe Game do
  let(:player1) { Player.new(name: 'P 1') }
  let(:player2) { Player.new(name: 'P 2') }
  let(:game) { Game.new([player1, player2]) }
  describe 'initialize' do
    it 'add the given players' do
      expect(game.players).to include player1
      expect(game.players).to include player2
    end
  end

  describe 'start' do
  end
end
