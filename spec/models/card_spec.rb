require 'spec_helper'

describe Card do
  it 'creates a card from a rank and suit string' do
    created_card = Card.with_rank_and_suit_from_string('10H')
    expect(created_card.rank).to eq '10'
    expect(created_card.suit).to eq 'H'
  end

  describe '#suit and #rank' do
      it 'has a suit and a rank' do
        card = Card.new(rank: '2', suit: 'S')
        expect(card.suit).to eq 'S'
        expect(card.rank).to eq '2'
      end
  end

  describe '#==' do
    it 'answers true when two cards have same values' do
      card1 = Card.new(rank: 'rank', suit: 'suit')
      card2 = Card.new(rank: 'rank', suit: 'suit')
      expect(card1 == card2).to be true
    end

    it 'answers false when two cards do not have same values' do
      card1 = Card.new(rank: 'rank', suit: 'suit')
      card2 = Card.new(rank: 'differentrank', suit: 'suit')
      expect(card1 == card2).to be false

      card2 = Card.new(rank: 'rank', suit: 'differentsuit')
      expect(card1 == card2).to be false
    end
  end

  describe '#eql?' do
    it 'answers true when two cards have same values' do
      card1 = Card.new(rank: 'rank', suit: 'suit')
      card2 = Card.new(rank: 'rank', suit: 'suit')
      expect(card1.eql?(card2)).to be true
    end
    it 'answers false when two cards do not have same values' do
      card1 = Card.new(rank: 'rank', suit: 'suit')
      card2 = Card.new(rank: 'differentrank', suit: 'suit')
      expect(card1.eql?(card2)).to be false

      card2 = Card.new(rank: 'rank', suit: 'differentsuit')
      expect(card1.eql?(card2)).to be false
    end
  end

  describe '#rank_value' do
    it 'answers value corresponding to numeric rank string' do
      card = Card.new(rank: '5', suit: 'suit')
      expect(card.rank_value).to eq 5
    end
  end

  describe '#to_s' do
    it 'answers a string with rank and suit' do
      card = Card.new(rank: 'arank', suit: 'asuit')
      expect(card.to_s).to eq 'arankasuit'
    end
  end

  it 'provides a hash of itself' do
    card = build(:card, rank: 'A', suit: 'S')
    card_hash = card.to_hash
    expect(card_hash[:rank]).to eq 'A'
    expect(card_hash[:suit]).to eq 'S'
  end
end
