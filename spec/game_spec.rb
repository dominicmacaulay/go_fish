# frozen_string_literal: true

require_relative '../lib/player'
require_relative '../lib/game'
require_relative '../lib/card'
require 'spec_helper'

# test go fish game
RSpec.describe Game do
  let(:player1) { Player.new(name: 'P 1') }
  let(:player2) { Player.new(name: 'P 2') }
  let(:game) { Game.new([player1, player2]) }
  describe '#initialize' do
    let(:deck_length) { 52 }
    it 'add the given players' do
      expect(game.players).to include player1
      expect(game.players).to include player2
    end
    it 'makes a new deck when called' do
      expect(game.deck.cards.count).to eql deck_length
    end
  end

  describe '#start' do
    let(:deal_number) { 5 }
    it 'shuffles the deck' do
      expect(game.deck).to receive(:shuffle).once
      game.start
    end
    it 'deals 5 cards to each player' do
      game.start
      expect(game.players.first.hand.length).to eql deal_number
      expect(game.players.last.hand.length).to eql deal_number
    end
  end

  describe '#deal_to_player_if_necessary' do
    it 'should only deal one card to the player if they do not have a card' do
      expect(game.current_player.hand_count).to be 0
      game.deal_to_player_if_necessary
      expect(game.current_player.hand_count).to be 1
      game.deal_to_player_if_necessary
      expect(game.current_player.hand_count).to be 1
    end
  end

  describe '#play_round' do
    before do
      player1.add_to_hand([Card.new(rank: '4', suit: 'Hearts'), Card.new(rank: '8', suit: 'Spades')])
      player2.add_to_hand([Card.new(rank: '4', suit: 'Spades'), Card.new(rank: '9', suit: 'Spades')])
    end
    it 'runs transaction and returns message if the asked player has the card' do
      message = 'P 1 took one 4 from P 2.'
      expect(game.play_round(other_player: player2, rank: '4')).to eql message
      expect(player1.hand.select { |card| card.rank == '4' }.count).to be 2
      expect(player2.hand.select { |card| card.rank == '4' }.count).to be 0
    end
    it 'runs transaction and returns message if the asked player has multiple cards' do
      message = "P 1 took two 4's from P 2."
      player2.add_to_hand(Card.new(rank: '4', suit: 'Clubs'))
      expect(game.play_round(other_player: player2, rank: '4')).to eql message
      expect(player1.hand.select { |card| card.rank == '4' }.count).to be 3
      expect(player2.hand.select { |card| card.rank == '4' }.count).to be 0
    end
    it 'returns Go Fish and draws from the pile if the other player doesn not have the rank' do
      message = 'Go Fish! You took a Jack of Hearts from the pond.'
      game = Game.new([player1, player2], [Card.new(rank: 'Jack', suit: 'Hearts')])
      expect(game.play_round(other_player: player2, rank: '8')).to eql message
    end
    it 'returns Go Fish and draws from the pile if the other player doesn not have the rank' do
      message = 'Go Fish! You took a Jack of Hearts from the pond.'
      game = Game.new([player1, player2], [Card.new(rank: 'Jack', suit: 'Hearts')])
      game.current_player = player2
      expect(game.play_round(other_player: player1, rank: '9')).to eql message
    end
    it 'returns a message indicating the pile is empty' do
      message = 'Go Fish! Sorry, there are no fish in the pond (The draw pile is empty).'
      game = Game.new([player1, player2], [Card.new(rank: 'Jack', suit: 'Hearts')])
      game.deck.deal
      game.current_player = player2
      expect(game.play_round(other_player: player1, rank: '9')).to eql message
    end
    it 'changes the player if the player has not gained cards' do
      game.play_round(other_player: player2, rank: '8')
      expect(game.current_player).to be player2
    end
    it 'does not change the player if they gained cards' do
      game.play_round(other_player: player2, rank: '4')
      expect(game.current_player).to be player1
    end
    it "calls the current player's make books method" do
      player1.add_to_hand([Card.new(rank: '4', suit: 'Diamonds'), Card.new(rank: '4', suit: 'Clubs')])
      game.play_round(other_player: player2, rank: '4')
      expect(player1.book_count).to be 1
    end
  end

  describe '#display_winner' do
    let(:books) { make_books(13) }
    it 'declares the winner with the most books' do
      winner = Player.new(name: 'Winner', books: books.shift(7))
      loser = Player.new(name: 'Loser', books: books.shift(6))
      winner_game = Game.new([winner, loser], [0])
      winner_game.deck.deal
      message = 'Winner won the game with 7 books totalling in 28'
      expect(winner_game.display_winner).to eql message
    end
    it 'in case of a book tie, declares the winner with the highest book value' do
      winner = Player.new(name: 'Winner', books: books.pop(6))
      loser1 = Player.new(name: 'Loser', books: books.shift(6))
      loser2 = Player.new(name: 'Loser', books: books.shift(1))
      winner_game = Game.new([winner, loser1, loser2], [0])
      winner_game.deck.deal
      message = 'Winner won the game with 6 books totalling in 63'
      expect(winner_game.display_winner).to eql message
    end
    it 'in case of total tie, display tie messge' do
      winner = Player.new(name: 'Winner', books: [books[1], books[3], books[5], books[7], books[9], books[11]])
      loser1 = Player.new(name: 'Loser', books: [books[0], books[2], books[4], books[8], books[10], books[12]])
      loser2 = Player.new(name: 'Loser', books: [books[6]])
      winner_game = Game.new([winner, loser1, loser2], [0])
      winner_game.deck.deal
      message = 'Winner and Loser tied with 6 books totalling in 42'
      expect(winner_game.display_winner).to eql message
    end
  end
  describe 'smoke test' do
    fit 'runs test' do
      game.start
      until game.winners
        game.deal_to_player_if_necessary
        current_index = game.players.index(game.current_player)
        other_player = game.players[(current_index + 1) % game.players.count]
        rank = game.current_player.hand.sample.rank
        puts "#{game.current_player.name} is asking for #{rank}'s"
        puts game.play_round(other_player: other_player, rank: rank)
      end
      puts game.display_winners
    end
  end
end

def make_books(times)
  deck = retrieve_one_deck
  books = []
  times.times do
    books.push(Book.new(deck.shift))
  end
  books
end

def retrieve_one_deck
  Card::RANKS.map do |rank|
    Card::SUITS.flat_map do |suit|
      Card.new(rank: rank, suit: suit)
    end
  end
end
