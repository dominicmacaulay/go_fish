# frozen_string_literal: true

# class for the socket runner
class SocketRunner
  attr_reader :game, :clients

  def initialize(game, clients)
    @game = game
    @clients = clients
    @rank = nil
    @opponent = nil
    @rank_prompted = false
    @opponent_prompted = false
  end

  def start
    game.start
    play_game
  end

  def play_game
    clients.each_value { |client| send_message(client, 'You have joined the game!') }
    # game_loop until game.winners
    # clients.each { |client| send_message(client, game.display_winners) }

  end

  def game_loop
    return unless check_player_and_get_rank
  end

  def check_player_and_get_rank
    return false unless player_can_play?(game.current_player.dup)


  end

  private

  def player_can_play?(player)
    message = game.deal_to_player_if_necessary
    return true if message.nil?

    current_player = game.players.detect { |game_player| game_player.name == player.name }
    send_message(clients[current_player], message)
    false
  end

  def send_message(client, text)
    binding.irb
    client.puts(text)
  end
end
