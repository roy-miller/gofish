class Request
  attr_accessor :originator, :recipient, :card_rank, :outcome, :cards_returned

  def initialize(originator: nil, recipient: nil, card_rank: nil)
    @originator = originator
    @recipient = recipient
    @card_rank = card_rank
    @cards_returned = []
  end

  def cards_returned?
    @cards_returned.any?
  end

  def go_fish?
    @cards_returned.empty?
  end

end
