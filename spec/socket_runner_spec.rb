# frozen_string_literal: true

require_relative '../lib/socket_runner'
require_relative '../lib/client'
require_relative '../lib/socket_server'

RSpec.describe SocketRunner do
  before(:each) do
    @server = SocketServer.new
    @server.start
    sleep(0.1)
    @client1_name = 'P 1'
    @client2_name = 'P 2'
    @client1 = create_client(@client1_name)
    @client2 = create_client(@client2_name)
    @game = @server.create_game_if_possible
    @runner = @server.create_runner(@game)
  end

  after(:each) do
    @server.stop
    @client1.close
    @client2.close
  end

  describe 'game_loop' do
    before do
      @client1.capture_output
      @client2.capture_output
    end
    it 'should send a message and return immediately if the player cannot play' do
      @game.deck.clear_cards
      @runner.game_loop
      expect(@client1.capture_output).to match 'Sorry'
      expect(@game.current_player.name).to eql @client2_name
    end
    it "should display the player's hand if the player can play" do
      @game.start
      @runner.game_loop
      expect(@client1.capture_output).to match 'You have'
    end
    it 'should prompt the player to give a rank' do
      @game.start
      @runner.game_loop
      expect(@client1.capture_output).to match 'Enter the rank'
    end
    it 'should only prompt once' do
      @game.start
      @runner.game_loop
      @client1.capture_output
      @runner.game_loop
      expect(@client1.capture_output).not_to match 'Enter the rank'
    end
    it "should return and not change the round's rank if the player has not given a rank" do
      @game.start
      @runner.game_loop
      expect(@runner.rank).to be nil
    end
    it 'should not change the rank if the player gives an invalid rank' do
      @game.start
      @client1.provide_input('14')
      @runner.game_loop
      expect(@runner.rank).to be nil
    end
    it 'should change the rank if the player gives a valid rank' do
      @game.start
      player1_card = @game.current_player.hand.first
      @client1.provide_input(player1_card.rank)
      @runner.game_loop
      expect(@runner.rank).to match player1_card.rank
    end
  end
end

def create_client(name)
  client = Client.new(@server.port_number)
  @server.accept_new_client
  client.provide_input(name)
  @server.assign_client_name_to_player
  client
end
