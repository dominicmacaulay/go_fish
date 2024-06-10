# frozen_string_literal: true

require 'socket'
require_relative 'player'
require_relative 'game'
require_relative 'socket_runner'

# runs interactions between the clients and the server
class SocketServer
  attr_accessor :games, :pending_clients, :clients, :unnamed_clients, :can_send_no_clients_message, :clients_not_greeted
  attr_reader :players_per_game

  def initialize(players_per_game = 2)
    @players_per_game = players_per_game
    @games = []
    @pending_clients = []
    @unnamed_clients = []
    @clients = {}
    @clients_not_greeted = []
    @can_send_no_clients_message = true
  end

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def stop
    @server&.close
  end

  def accept_new_client
    client = @server.accept_nonblock
    send_message_to_client(client, 'Enter your name (at least 3 characters): ')
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

  def create_game_if_possible
    if pending_clients.count >= players_per_game
      games.push(Game.new(retrieve_players))
      return games.last
    end
    greet_ungreeted_clients
  end

  def run_game(game)
    runner = create_runner(game)
    runner.start
    runner
  end

  private

  def create_runner(game)
    game_clients = game.players.map { |player| clients.key(player) }
    SocketRunner.new(game, game_clients)
  end

  def greet_ungreeted_clients
    clients_not_greeted.each { |client| send_message_to_client(client, 'Waiting for other player(s) to join') }
    clients_not_greeted.clear
    nil
  end

  def retrieve_players
    players_per_game.times.map do
      clients[pending_clients.shift]
    end
  end

  def capture_client_input(client, delay = 0.1)
    sleep(delay)
    client.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    nil
  end

  def send_message_to_client(client, message)
    client.puts(message)
  end

  def create_player_if_possible(client)
    name = capture_client_input(client)
    return if name.nil?

    if name.length < 3
      send_message_to_client(client, 'Retry! Enter your name (at least 3 characters): ')
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
    clients_not_greeted.push(client)
    pending_clients.push(client)
    unnamed_clients.delete(client)
    clients[client] = Player.new(name: name)
  end
end
