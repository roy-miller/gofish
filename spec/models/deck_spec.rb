require 'spec_helper'

describe Deck do
  context 'empty' do
    let(:deck) { build(:deck) }

    it 'should answer false' do
      expect(deck.has_cards?).to be false
    end
  end

  context 'with cards' do
    let(:deck) { build(:deck, :full) }

    it 'has a full set of playing cards' do
      expect(deck.cards.count).to eq 52
    end

    it 'says it has cards' do
      expect(deck.has_cards?).to be true
    end

    it 'adds a card' do
      deck.add(Card.new(rank: 'rank', suit: 'suit'))
      expect(deck.cards.count).to eq 53
    end

    it 'removes a card' do
      card = Card.new(rank: 'rank', suit: 'suit')
      deck.cards << card
      expect(deck.cards).to include card
      deck.remove(card)
      expect(deck.cards).not_to include card
    end

    # TODO what's a better way to test this?
    it 'shuffles cards' do
      card1 = Card.new(rank: 'rank1', suit: 'suit1')
      card2 = Card.new(rank: 'rank2', suit: 'suit1')
      card3 = Card.new(rank: 'rank1', suit: 'suit2')
      deck.add(card1)
      deck.add(card2)
      deck.add(card3)

      deck.shuffle

      was_shuffled = deck.cards[0] != card1 &&
                     deck.cards[1] != card2 &&
                     deck.cards[2] != card3

      expect(was_shuffled).to be true
    end

    it 'should return the top card' do
      starting_card_count = deck.cards.count
      card = deck.give_top_card
      expect(card).not_to be_nil
      expect(deck.cards.count).to eq (starting_card_count - 1)
    end

    it 'should answer the number of cards' do
      expect(deck.card_count).to eq 52
    end
  end
end
