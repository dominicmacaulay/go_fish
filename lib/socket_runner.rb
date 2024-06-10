# frozen_string_literal: true

# class for the socket runner
class SocketRunner
  attr_reader :game, :clients

  def initialize(game, clients)
    @game = game
    @clients = clients
  end

  def start
  end
end
