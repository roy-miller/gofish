class Deck
  attr_accessor :cards

  def initialize
    @suits = ['S','C','H','D']
    @ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
    @cards = []
    @suits.each do |suit|
      @ranks.each do |rank|
        @cards << Card.new(rank: rank, suit: suit)
      end
    end
  end

  def add(card)
    @cards << card
  end

  def remove(card)
    @cards.delete(card)
  end

  def give_top_card
    @cards.pop
  end

  def shuffle
    @cards.shuffle!(random: Random.new(3))
  end

  def has_cards?
    !@cards.empty?
  end

  def card_count
    @cards.size
  end
end
