require 'spec_helper'

describe Book do
  let(:book) { Book.new }

  it 'adds a card when empty' do
    card = Card.new(rank: 'A', suit: 'S')
    book.add_card(card)
    expect(book.cards).to include card
  end

  it 'says it has no value when it has no cards' do
    expect(book.value).to eq Book::NO_VALUE
  end

  it 'says what card value it holds once it has a card' do
    card = Card.new(rank: 'A', suit: 'S')
    book.add_card(card)
    expect(book.value).to eq 'A'
  end

  it 'says it is not full when it does not have four cards' do
    expect(book.full?).to be false
  end

  it 'says how many cards it has' do
    card1 = Card.new(rank: 'A', suit: 'S')
    card2 = Card.new(rank: 'A', suit: 'C')
    [card1, card2].each { |card| book.add_card(card) }
    expect(book.card_count).to eq 2
  end

  it 'says it is full when it does have four cards' do
    card1 = Card.new(rank: 'A', suit: 'S')
    card2 = Card.new(rank: 'A', suit: 'C')
    card3 = Card.new(rank: 'A', suit: 'H')
    card4 = Card.new(rank: 'A', suit: 'D')
    [card1, card2, card3, card4].each { |card| book.add_card(card) }
    expect(book.full?).to be true
  end

  it 'does not add a card of the wrong kind' do
    card1 = Card.new(rank: 'A', suit: 'S')
    book.add_card(card1)
    card_of_wrong_kind = Card.new(rank: '9', suit: 'D')
    book.add_card(card_of_wrong_kind)
    expect(book.cards).not_to include card_of_wrong_kind
  end
end
