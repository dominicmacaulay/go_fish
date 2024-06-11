# frozen_string_literal: true

# class for the socket runner
class SocketRunner
  attr_reader :game, :clients
  attr_accessor :rank, :opponent, :rank_prompted, :opponent_prompted

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
    game_loop until game.winners
    clients.each { |client| send_message(client, game.display_winners) }
  end

  def game_loop
    return unless player_can_play?(game.current_player.dup)

    send_message(clients[game.current_player], game.current_player.display_hand)
    return unless player_rank_chosen?
  end

  private

  def player_rank_chosen?
    prompt_rank
    rank = retreive_message_from_player(clients[game.current_player])
    return false if rank.nil? || rank_invalid?(rank)

    self.rank = rank
    true
  end

  def prompt_rank
    unless rank_prompted == true
      send_message(clients[game.current_player], 'Enter the rank you want to ask for:')
      self.rank_prompted = true
    end
  end

  def rank_invalid?(rank)
    unless game.player_has_rank?(rank)
      send_message(clients[game.current_player], 'Invalid_input. Try again:')
      return true
    end
    false
  end

  def player_can_play?(player)
    message = game.deal_to_player_if_necessary
    return true if message.nil?

    current_player = game.players.detect { |game_player| game_player.name == player.name }
    send_message(clients[current_player], message)
    false
  end

  def send_message(client, text)
    client.puts(text)
  end

  def retreive_message_from_player(client, delay = 0.1)
    sleep(delay)
    client.read_nonblock(1000).chomp.downcase # not gets which blocks
  rescue IO::WaitReadable
    ''
  end
end
