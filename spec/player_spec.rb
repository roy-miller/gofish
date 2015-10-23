require 'spec_helper'

describe(Player) do
  let(:player) { Player.new }

  it 'creates a player with a name and no hand' do
    expect(player.name).to eq 'default'
    expect(player.hand).to be_empty
  end

  it 'adds card to new book if book corresponding to card does not exist' do
    card = Card.new(rank: 'Q', suit: 'H')
    player.add_card_to_hand(card)
    expect(player.hand.first.cards).to include card
  end

  it 'collects a book when added card completes a book' do
    book = Book.new
    book.add_card(Card.new(rank: '2', suit: 'D'))
    book.add_card(Card.new(rank: '2', suit: 'S'))
    book.add_card(Card.new(rank: '2', suit: 'C'))
    player.hand << book
    card = Card.new(rank: '2', suit: 'C')
    player.add_card_to_hand(card)
    expect(player.full_books.count).to eq 1
  end

  it 'answers true when player has no cards' do
    expect(player.out_of_cards?).to be true
  end

  it 'answers false when player has cards' do
    player.hand << Card.new(rank: 'irrelevant', suit: 'irrelevant')
    expect(player.out_of_cards?).to be false
  end

  it 'answers the count of cards in all of its books' do
    (2..4).each do |book_number|
      book = Book.new
      book.add_card(Card.new(rank: book_number, suit: 'D'))
      player.hand << book
    end
    expect(player.card_count).to eq 3
  end
end
