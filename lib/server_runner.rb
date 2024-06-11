# frozen_string_literal: true

# lib/war_socket_server_runner.rb

require_relative 'socket_server'

server = SocketServer.new
server.start
while true do
  begin
  server.accept_new_client
  server.assign_client_name_to_player
  game = server.create_game_if_possible
  if game
    server.run_game(game)
  end
rescue
  server.stop
end
end