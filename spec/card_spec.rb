require 'spec_helper'

describe Card do
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
end
