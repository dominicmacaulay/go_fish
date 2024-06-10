# frozen_string_literal: true

require 'socket'
require_relative 'player'
require_relative 'game'
# require_relative 'socket_runner'

# runs interactions between the clients and the server
class SocketServer
  attr_accessor :games, :pending_clients, :clients, :unnamed_clients, :can_send_no_clients_message
  attr_reader :players_per_game, :server, :port_number

  def initialize(players_per_game = 2, port_number = 3336)
    @players_per_game = players_per_game
    @games = []
    @pending_clients = []
    @unnamed_clients = []
    @clients = {}
    @port_number = port_number
    @can_send_no_clients_message = true
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def stop
    @server&.close
  end

  def accept_new_client
    client = @server.accept_nonblock
    client.puts('Enter your name (at least 3 characters): ')
    unnamed_clients.push(client)
    self.can_send_no_clients_message = true
  rescue IO::WaitReadable, Errno::EINTR
    send_no_clients_message
  end

  def assign_client_name_to_player
    unnamed_clients.each do |client|
      create_player_if_possible(client)
    end
  end

  def capture_client_input(client, delay = 0.1)
    sleep(delay)
    client.read_nonblock(1000).chomp.downcase # not gets which blocks
  rescue IO::WaitReadable
    nil
  end

  private

  def create_player_if_possible(client)
    name = capture_client_input(client)
    return if name.nil?

    if name.length >= 0 && name.length < 3
      client.puts('Enter your name (at least 3 characters): ')
    else
      create_client(client, name)
    end
  end

  def send_no_clients_message
    return unless can_send_no_clients_message == true

    puts 'No client to accept'
    self.can_send_no_clients_message = false
  end

  def create_client(client, name)
    pending_clients.push(client)
    unnamed_clients.delete(client)
    clients[client] = Player.new(name: name)
  end
end
