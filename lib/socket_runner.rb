# frozen_string_literal: false

# class for the socket runner
class SocketRunner
  attr_reader :game, :clients
  attr_accessor :rank, :opponent, :rank_prompted, :opponent_prompted, :info_shown

  def initialize(game, clients)
    @game = game
    @clients = clients
    @info_shown = false
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
    clients.each_value do |client|
      send_message(client, 'You have joined the game!')
      send_message(client, '')
    end

    game_loop until game.winners

    results = game.display_winners
    clients.each_value { |client| send_message(client, results) }
  end

  def game_loop
    return unless player_can_play?(game.current_player.dup)

    show_info
    return unless player_rank_chosen? && player_opponent_chosen?

    result = game.play_round(other_player: opponent, rank: rank)
    display_result(result)

    reset_class_variables
  end

  private

  def display_result(result)
    clients.each_value do |client|
      send_message(client, '')
      send_message(client, result)
      send_message(client, '')
    end
  end

  def reset_class_variables
    self.info_shown = false
    self.rank = nil
    self.opponent = nil
    self.rank_prompted = false
    self.opponent_prompted = false
  end

  def show_info
    return if info_shown == true

    send_message(clients[game.current_player], "Your book count is #{game.current_player.book_count}")
    message = show_opponents(retrieve_opponents.compact)
    send_message(clients[game.current_player], message)
    send_message(clients[game.current_player], game.current_player.display_hand)
    self.info_shown = true
  end

  def show_opponents(opponents)
    message = 'Your opponents are '
    opponents.each do |opponent|
      message.concat('and ') if opponent == opponents.last && opponent != opponents.first
      message.concat(opponent)
      message.concat(', ') unless opponent == opponents.last
    end
    message
  end

  def retrieve_opponents
    game.players.map do |player|
      player.name unless player == game.current_player
    end
  end

  def player_opponent_chosen?
    return true unless opponent.nil?

    prompt_opponent_choice
    input = retreive_message_from_player(clients[game.current_player])
    result = game.match_player_to_name(input)
    return false if input.nil? || opponent_invalid?(result)

    self.opponent = result
    true
  end

  def opponent_invalid?(result)
    if result.is_a?(String)
      send_message(clients[game.current_player], result)
      return true
    end
    false
  end

  def prompt_opponent_choice
    return if opponent_prompted == true

    send_message(clients[game.current_player], 'Enter the opponent you want to ask: ')
    self.opponent_prompted = true
  end

  def player_rank_chosen?
    return true unless rank.nil?

    prompt_rank_choice
    input = retreive_message_from_player(clients[game.current_player])
    return false if input.nil? || rank_invalid?(input)

    self.rank = input
    true
  end

  def prompt_rank_choice
    return if rank_prompted == true

    send_message(clients[game.current_player], 'Enter the rank you want to ask for: ')
    self.rank_prompted = true
  end

  def rank_invalid?(rank)
    unless game.player_has_rank?(rank)
      send_message(clients[game.current_player], 'Invalid input. Try again: ')
      return true
    end
    false
  end

  def player_can_play?(player)
    message = game.deal_to_player_if_necessary
    return true if message.nil?

    current_player = game.players.detect { |game_player| game_player.name == player.name }
    send_message(clients[current_player], message)
    message.include?('took cards')
  end

  def send_message(client, text)
    client.puts(text)
  end

  def retreive_message_from_player(client, delay = 0.1)
    sleep(delay)
    client.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    nil
  end
end
