class Card
  attr_accessor :suit, :rank
  RANKS = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
  SUITS = ['S','C','H','D']

  def self.with_rank_and_suit_from_string(rank_and_suit_string)
    rank = rank_and_suit_string.chars.first
    rank = '10' if rank == '1'
    suit = rank_and_suit_string.chars.last
    Card.new(rank: rank, suit: suit)
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

  def hash
    @rank.hash ^ @suit.hash
  end

  def rank_value
    RANKS.index(@rank) + 2
  end

  def to_s
    "#{@rank}#{@suit}"
  end

  def to_hash
    hash = {}
    hash[:rank] = @rank
    hash[:suit] = @suit
    hash
  end
end
