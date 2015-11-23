require_relative './book.rb'
require_relative './card.rb'

class Player
  attr_accessor :number, :hand, :books

  def initialize(number = 1)
    @number = number
    @hand = []
    @books = []
  end

  def add_card_to_hand(card)
    @hand << card
    cards_with_rank = @hand.select { |c| c.rank == card.rank }
    if cards_with_rank.count == 4
      add_book(cards_with_rank)
      remove_cards_from_hand(cards_with_rank)
    end
  end

  def remove_cards_from_hand(cards)
    @hand.reject! { |card| cards.include? card }
  end

  def add_book(cards)
    book = Book.new
    cards.each { |card| book.add_card(card) }
    @books << book
  end

  def add_cards_to_hand(cards)
    cards.each { |card| self.add_card_to_hand(card) }
  end

  def card_count
    @hand.count
  end

  def book_count
    @books.count
  end

  def out_of_cards?
    @hand.empty?
  end

  def receive_request(request)
    cards_to_return_and_keep = @hand.partition { |card| card.rank == request.card_rank }
    request.cards_returned = cards_to_return_and_keep.slice(0,1).flatten!
    @hand = cards_to_return_and_keep.slice(1,1).flatten!
    request
  end

  def receive_response(response)
    add_cards_to_hand(response.cards_returned)
  end

  def to_hash
    hash = {}
    hash[:number] = @number
    hash[:hand] = @hand.map { |card| card.to_hash }
    hash[:books] = @books.map { |book| book.to_hash }
    hash
  end
end
