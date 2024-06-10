# frozen_string_literal: true

require 'spec_helper'
require 'socket'
require_relative '../lib/socket_server'
require_relative '../lib/game'

class MockWarSocketClient
  attr_reader :socket, :output, :name

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    @output = ''
  end

  def close
    @socket&.close
  end
end

RSpec.describe SocketServer do
  before(:each) do
    @clients = []
    @server = SocketServer.new
    @server.start
    sleep(0.1)
  end

  after(:each) do
    @server.stop
    @clients.each(&:close)
  end

  it 'is not listening on a port before it is started' do
    @server.stop
    expect { MockWarSocketClient.new(@server.port_number) }.to raise_error(Errno::ECONNREFUSED)
  end

  describe '#accept_new_client' do
    it 'accepts new clients into the unnamed list' do
      create_client
      create_client
      expect(@server.unnamed_clients.length).to be @clients.length
    end
    it 'prompts the clients to give their name' do
      client1 = create_client
      expect(client1.capture_output).to match 'name'
    end
  end

  describe 'assign_client_name_to_player' do
    it 'does not create a client/player in clients if no name is provided' do
      create_client
      @server.assign_client_name_to_player
      expect(@server.clients).to be_empty
    end
    it 'send retry message and does not create if name is not long enough' do
      client1 = create_client
      client1.capture_output
      client1.provide_input('D')
      @server.assign_client_name_to_player
      expect(@server.clients).to be_empty
      expect(client1.capture_output).to match 'name'
    end
    it 'send retry message and does not create if player just hits space' do
      client1 = create_client
      client1.capture_output
      client1.provide_input('')
      @server.assign_client_name_to_player
      expect(@server.clients).to be_empty
      expect(client1.capture_output).to match 'name'
    end
    it 'creates a client/player in clients if a name is provided' do
      client1 = create_client
      client1.provide_input('Dom')
      @server.assign_client_name_to_player
      expect(@server.clients).not_to be_empty
    end
  end

  # describe '#create_game_if_possible' do
  #   it 'starts a game only if there are enough players' do
  #     create_client('Player 1')
  #     @server.create_game_if_possible
  #     expect(@server.games.count).to be 0
  #     create_client('Player 2')
  #     @server.create_game_if_possible
  #     expect(@server.games.count).to be 1
  #   end

  #   it 'returns a WarGame object if there are enough players' do
  #     MockWarSocketClient.new(@server.port_number)
  #     @server.accept_new_client('Player 1')
  #     MockWarSocketClient.new(@server.port_number)
  #     @server.accept_new_client('Player 2')
  #     game = @server.create_game_if_possible
  #     expect(game).to respond_to(:start)
  #   end

  #   it 'sends the client a pending message when there are not enough players yet' do
  #     client1 = create_client('Player 1')
  #     client1.capture_output
  #     @server.create_game_if_possible
  #     expect(client1.capture_output.chomp).to eq('Waiting for other player(s) to join')
  #     @server.create_game_if_possible
  #     expect(client1.capture_output).to eq ''
  #   end

  #   it 'adds the client to the ungreeted array and removes them once they have been greeted' do
  #     create_client('Player 1')
  #     expect(@server.clients_not_greeted.length).to eql 1
  #     @server.create_game_if_possible
  #     expect(@server.clients_not_greeted.empty?).to be true
  #   end
  # end

  # describe '#get_name_and_assign_client' do
  #   before do
  #     @mock_client = MockWarSocketClient.new(@server.port_number)
  #     @clients.push(@mock_client)
  #     @server_client = @server.server.accept_nonblock
  #     @server.get_name_and_assign_client(@server_client, nil)
  #   end

  #   it 'exits if no name is given or retrieved' do
  #     expect(@server.pending_clients).not_to include(@server_client)
  #   end
  #   it 'adds the client to the lists if name is given' do
  #     @mock_client.provide_input('Jack')
  #     @server.get_name_and_assign_client(@server_client, nil)
  #     expect(@server.pending_clients).to include(@server_client)
  #     expect(@server.clients).to include(@server_client)
  #     expect(@server.clients_not_greeted).to include(@server_client)
  #   end
  # end

  # describe '#capture_output' do
  #   it "receives the client's input" do
  #     client1 = create_client('P 1')
  #     client1.provide_input('ready')
  #     expect(@server.retrieve_client_response(@server.pending_clients.first)).to eq('ready')
  #   end
  # end
  def create_client
    client = MockWarSocketClient.new(@server.port_number)
    @clients.push(client)
    @server.accept_new_client
    client
  end
end
