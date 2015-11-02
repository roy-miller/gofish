class Card
  attr_accessor :suit, :rank

  def self.with_rank_and_suit_from_string(rank_and_suit_string)
    rank, suit = Card.rank_and_suit_from_string(rank_and_suit_string)
    Card.new(rank: rank, suit: suit)
  end

  def self.rank_and_suit_from_string(rank_and_suit_string)
    rank = rank_and_suit_string.chars.first
    rank = '10' if rank == '1'
    suit = rank_and_suit_string.chars.last
    [rank, suit]
  end

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
