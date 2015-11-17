require_relative './book.rb'
require_relative './card.rb'

class Player
  attr_accessor :number, :hand, :books

  def self.with_number_and_cards(number: 1, cards: [])
    player = Player.new(number)
    cards.each do |card_string|
      card = Card.with_rank_and_suit_from_string(card_string)
      player.add_card_to_hand(card)
    end
    player
  end

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

  def add_book(cards)
    book = Book.new
    cards.each do |card|
      book.add_card(card)
    end
    @books << book
  end

  def add_cards_to_hand(cards)
    cards.each do |card|
      self.add_card_to_hand(card)
    end
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
    # TODO use array partition here
    cards_to_return = cards_for_rank(request.card_rank)
    request.cards_returned = cards_to_return
    remove_cards_from_hand(cards_to_return)
    request
  end

  def remove_cards_from_hand(cards)
    @hand.reject! { |card| cards.include? card }
  end

  def receive_response(response)
    add_cards_to_hand(response.cards_returned)
  end

  def cards_for_rank(rank)
    @hand.select { |card| card.rank == rank }
  end

  def has_cards_with_rank_and_suit(card_strings)
    has_all_cards = false
    card_strings.each do |card_string|
      rank, suit = Card.rank_and_suit_from_string(card_string)
      return true if @hand.select { |card| card.rank == rank && card.suit == suit }.any?
    end
    has_all_cards
  end
end
