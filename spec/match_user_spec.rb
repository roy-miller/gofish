require 'spec_helper'

describe MatchUser do
  let(:user) { User.new(id: 123, name: 'user1') }
  let(:player) { Player.with_number_and_cards(number: 1, cards: ['QH', 'AS', '6C']) }
  let(:match) { Match.new }
  let(:match_user) { MatchUser.new(match: match, user: user, player: player) }

  before do
    match.match_users << match_user
    match_user.match = match
  end

  it 'answers the name for its user' do
    expect(match_user.name).to eq 'user1'
  end

  it 'answers the id for its user' do
    expect(match_user.id).to eq 123
  end

  it 'says user has no cards when game player has none' do
    player.hand = []
    expect(match_user.out_of_cards?).to be true
  end

  it 'says user has cards when game player has some' do
    expect(match_user.has_cards?).to be true
  end


  it 'notifies client when a match starts' do
    expect(Pusher).to receive(:trigger).with('player_channel_0_123', 'match_start_event', { message: 'match started' })
    match_user.start_playing
  end

  it 'notifies client when a match changes' do
    expect(Pusher).to receive(:trigger).with('player_channel_0_123', 'match_change_event', { message: 'match changed' })
    match_user.match_changed
  end
end
