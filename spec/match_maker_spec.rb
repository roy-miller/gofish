require 'spec_helper'

describe MatchMaker do
  let(:match_maker) { MatchMaker.new }
  let(:existing_user) { User.new(id: 123, name: 'existing') }
  let(:existing_player) { Player.new(1) }

  before do
    User.reset_users
    Match.reset
  end

  it 'creates a new pending match when none exists' do
    match = match_maker.add_pending_user(id: nil, name: 'newuser')
    expect(User.users.count).to eq 1 # this is a side effect, is that wrong?
    expect(User.users.first.name).to eq 'newuser'
    expect(match.pending?).to be true
  end

  it 'adds user to existing match' do
    User.users << existing_user
    Match.matches[0] = Match.new(game: nil, match_users: [])
    match = match_maker.add_pending_user(id: 123, name: 'existing')
    expect(Match.matches.count).to eq 1
    expect(match.match_users.count).to eq 1
  end
end
