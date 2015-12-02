require 'spec_helper'

describe Book do
  let(:book) { build(:book) }

  it 'adds a card when empty' do
    card = build(:card, rank: 'A', suit: 'S')
    book.add_card(card)
    expect(book.cards).to include card
  end

  it 'says it has no value when it has no cards' do
    expect(book.value).to eq Book::NO_VALUE
  end

  it 'says what card value it holds once it has a card' do
    card = build(:card, rank: 'A', suit: 'S')
    book.add_card(card)
    expect(book.value).to eq 'A'
  end

  it 'says how many cards it has' do
    card1 = build(:card, rank: 'A', suit: 'S')
    card2 = build(:card, rank: 'A', suit: 'C')
    [card1, card2].each { |card| book.add_card(card) }
    expect(book.card_count).to eq 2
  end

  it 'does not add a card of the wrong kind' do
    card1 = build(:card, rank: 'A', suit: 'S')
    book.add_card(card1)
    card_of_wrong_kind = build(:card, rank: '9', suit: 'D')
    book.add_card(card_of_wrong_kind)
    expect(book.cards).not_to include card_of_wrong_kind
  end

  it 'provides a hash of itself' do
    card1 = build(:card, rank: 'A', suit: 'S')
    card2 = build(:card, rank: 'A', suit: 'C')
    card3 = build(:card, rank: 'A', suit: 'H')
    card4 = build(:card, rank: 'A', suit: 'D')
    [card1, card2, card3, card4].each { |card| book.add_card(card) }
    book_hash = book.to_hash
    [card1, card2, card3, card4].each do |card|
      expect(book_hash[:cards]).to include(card.to_hash)
    end
  end
end
