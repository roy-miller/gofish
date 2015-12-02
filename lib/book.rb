class Book
  attr_accessor :cards
  NO_VALUE = 'none'

  def initialize
    @cards = []
  end

  def add_card(card)
    @cards << card if has_cards? && card.rank == value
    @cards << card if !has_cards?
  end

  def value
    value = has_cards? ? @cards.first.rank : NO_VALUE
  end

  def has_cards?
    @cards.any?
  end

  def card_count
    @cards.count
  end

  def to_hash
    hash = {}
    hash[:cards] = @cards.map { |card| card.to_hash }
    hash
  end
end
