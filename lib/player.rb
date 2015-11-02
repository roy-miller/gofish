require_relative './book.rb'
require_relative './card.rb'

class Player
  attr_accessor :name, :hand, :full_books

  def self.with_name_and_cards(name = 'playername', card_strings)
    player = Player.new(name)
    card_strings.each do |card_string|
      card = Card.with_rank_and_suit_from_string(card_string)
      player.add_card_to_hand(card)
    end
    player
  end

  def initialize(name = 'default')
    @name = name
    @hand = []
    @full_books = []
  end

  def add_card_to_hand(card)
    book = book_for_card(card)
    if book
      add_card_to_book(card, book)
    else
      new_book = Book.new
      new_book.add_card(card)
      @hand << new_book
    end
  end

  def add_card_to_book(card, book)
    book.add_card(card)
    if book.full?
      @hand.reject! { |book_in_hand| book_in_hand.value == book.value }
      @full_books << book
    end
  end

  def add_cards_to_hand(cards)
    cards.each do |card|
      self.add_card_to_hand(card)
    end
  end

  def card_count
    total = 0
    @hand.each do |book|
      total += book.card_count
    end
    total
  end

  def book_count
    @full_books.count
  end

  def out_of_cards?
    @hand.empty?
  end

  def book_for_card(card)
    book = @hand.select { |book| book.value == card.rank }.first
    book
  end

  def receive_request(request)
    # could give back books, but I'll stick with cards for now
    cards_to_return = cards_for_rank(request.card_rank)
    request.cards_returned = cards_to_return
    remove_cards_from_hand(cards_to_return)
    request
  end

  def remove_cards_from_hand(cards)
    # TODO more efficient way to do this?
    cards.each do |card|
      @hand.each do |book|
        book.cards.delete_if { |c| c == card }
      end
    end
    remove_empty_books
  end

  def remove_empty_books
    @hand.delete_if { |book| book.cards.empty? }
  end

  def receive_response(response)
    add_cards_to_hand(response.cards_returned)
  end

  def cards
    cards = []
    @hand.each do |book|
      cards << book.cards
    end
    cards.flatten!
  end

  def cards_for_rank(rank)
    cards = []
    @hand.each do |book|
      cards << book.cards if book.value == rank
    end
    cards.flatten!
    cards
  end

  def has_cards_with_rank_and_suit(card_strings)
    has_all_cards = false
    card_strings.each do |card_string|
      rank, suit = Card.rank_and_suit_from_string(card_string)
      return true if cards.select { |card| card.rank == rank && card.suit == suit }.any?
    end
    has_all_cards
  end
end
