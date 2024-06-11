# frozen_string_literal: true

require_relative '../lib/socket_runner'
require_relative '../lib/client'
require_relative '../lib/socket_server'

RSpec.describe SocketRunner do
  before(:each) do
    @server = SocketServer.new
    @server.start
    sleep(0.1)
    @client1 = create_client('P 1')
    @client2 = create_client('P 2')
    @game = @server.create_game_if_possible
    @runner = @server.create_runner(@game)
  end

  after(:each) do
    @server.stop
    @client1.close
    @client2.close
  end

  describe 'check_player_and_get_rank' do
    it 'should send a message and return false immediately if the player cannot play' do
      @game.deck.clear_cards
      @runner.game_loop
      expect(@client1.capture_output).to match 'Sorry'
    end
    it 'should return '
  end
end

def create_client(name)
  client = Client.new(@server.port_number)
  @server.accept_new_client
  client.provide_input(name)
  @server.assign_client_name_to_player
  client
end
