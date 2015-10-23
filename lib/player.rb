class Player
  attr_accessor :name, :hand, :full_books

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
    @full_books << book if book.full?
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

  def out_of_cards?
    @hand.empty?
  end

  def book_for_card(card)
    book = @hand.select { |book| book.value == card.rank }.first
    book
  end
end
