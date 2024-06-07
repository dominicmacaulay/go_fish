# frozen_string_literal: true

require_relative '../lib/player'
require 'spec_helper'

# test the player class
RSpec.describe Player do
  describe 'Initialize' do
    let(:player) { Player.new }
    it 'starts with a name by default' do
      expect(player.name).to eql 'A Mysterious Figure'
    end
    it 'starts with an empty books array' do
      expect(player.books.empty?).to be true
    end
    it 'starts with an empty hand' do
      expect(player.hand.empty?).to be true
    end
  end
end
