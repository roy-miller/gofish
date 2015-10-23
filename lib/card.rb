class Card
  attr_accessor :suit, :rank

  def initialize(rank:, suit:)
    @rank = rank
    @suit = suit
  end

  def ==(other)
    @rank == other.rank && @suit == other.suit
  end

  def eql?(other)
    self == other
  end

  def rank_value
    values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
    values.index(@rank) + 2
  end

  def to_s
    "#{@rank}#{@suit}"
  end
end
