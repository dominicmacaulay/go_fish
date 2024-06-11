# frozen_string_literal: true

require_relative 'client'

# lib/client_runner.rb

puts 'enter your server number: '
server = gets.chomp
if server.length >= 4
  server = server.to_i
else
  server = nil
end

client = Client.new(server)
loop do
  output = ''
  output = client.capture_output until output != ''
  if output.include?(':')
    print output
    client.provide_input(gets.chomp)
  else
    puts output
  end
end
