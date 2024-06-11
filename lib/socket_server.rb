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
      clients_not_greeted.delete_if { |client| !pending_clients.include?(client) }
      return games.last
    end
    greet_ungreeted_clients
  end

  def run_game(game)
    runner = create_runner(game)
    runner.start
  end

  def create_runner(game)
    clients_duplicate = clients.dup
    game_clients = clients_duplicate.keep_if { |key, value| game.players.include?(value) }
    SocketRunner.new(game, game_clients.invert)
  end

  private

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
    client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    nil
  end

  def send_message_to_client(client, message)
    client.puts(message)
  end

  def create_player_if_possible(client)
    name = capture_client_input(client)
    return if name.nil?

    return if name_too_short?(client, name)
    return if name_already_in_use?(client, name)

    create_client(client, name)
  end

  def name_already_in_use?(client, name)
    clients.each_value do |player|
      if player.name == name
        send_message_to_client(client, 'Sorry! That name is already in use!')
        return true
      end
    end
    false
  end

  def name_too_short?(client, name)
    return false unless name.length < 3

    send_message_to_client(client, 'Retry! Enter your name (at least 3 characters): ')
    true
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
