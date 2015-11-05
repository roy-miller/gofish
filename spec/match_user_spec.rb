require 'spec_helper'

describe MatchUser do
  let(:user) { User.new(id: 123, name: 'user1') }
  let(:player) { Player.with_number_and_cards(number: 1, cards: ['QH', 'AS', '6C']) }
  let(:match_user) { MatchUser.new(user: user, player: player) }

  it 'answers the name for its user' do
    expect(match_user.name).to eq 'user1'
  end

  it 'answers the id for its user' do
    expect(match_user.id).to eq 123
  end

  xit 'answers the hand for its player' do
  end

end
