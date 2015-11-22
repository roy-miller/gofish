require 'spec_helper'

describe Request do
  it 'says no cards were returned when there were none' do
    request = Request.new
    expect(request.cards_returned?).to be false
  end

  it 'says cards were returned when there were some' do
    request = Request.new
    request.cards_returned = [Card.new(rank: 'rank', suit: 'suit')]
    expect(request.cards_returned?).to be true
  end
end
