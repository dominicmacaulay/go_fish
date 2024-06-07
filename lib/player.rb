# frozen_string_literal: true

# card game player class
class Player
  attr_accessor :name, :books, :hand

  def initialize(name = 'A Mysterious Figure')
    @name = name
    @books = []
    @hand = []
  end

  def add_to_hand(cards)
    hand.push(*cards)
  end

  def remove_cards(rank)
    hand.map do |card|
      hand.delete(card) if card.rank == rank
    end
  end

  def hand_has_rank?(given_rank)
    hand.each do |card|
      return true if card.rank == given_rank
    end
    false
  end
end
