require 'spec_helper'

describe MatchUser do
  let(:user) { build(:user) }
  let(:player) { build(:player) }
  let(:match_user) { MatchUser.new(user: user, player: player) }

  it 'answers the name for its user' do
    expect(match_user.name).to eq user.name
  end

  it 'answers the id for its user' do
    expect(match_user.id).to eq user.id
  end

  it 'says user has no cards when game player has none' do
    player.hand = []
    expect(match_user.out_of_cards?).to be true
  end

  it 'says user has cards when game player has some' do
    player.hand = [build(:card)]
    expect(match_user.has_cards?).to be true
  end
end
