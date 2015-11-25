require 'spec_helper'

describe MatchMaker do
  let(:match_maker) { MatchMaker.new }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  it 'does not make a match when it does not have the right number of users' do
    expect(match_maker.match(user, 2)).to be_nil
  end

  it 'makes a match when it has the right number of users' do
    allow(match_maker).to receive(:push).and_return(nil)
    match_maker.match(user, 2)
    match = match_maker.match(another_user, 2)
    #expect(match_maker).to have_received(:push).once.with("wait_channel_#{user.id}", 'match_change_event', { message: "/matches/#{match.id}/users/#{user.id}" })
    #expect(match_maker).to have_received(:push).once.with("wait_channel_#{another_user.id}", 'match_change_event', { message: "/matches/#{match.id}/users/#{another_user.id}" })
    expect(match_maker).to have_received(:push).twice
    expect(match).to_not be_nil
    expect(match.users).to contain_exactly(user, another_user)
  end

  it 'starts a match with robots if not enough users join in time' do
    allow(match_maker).to receive(:trigger_start_timer).and_return(nil)
    match_maker.start_timeout_seconds = 0
    match_maker.match(user, 2)
    expect(match_maker).to have_received(:trigger_start_timer).once
  end

  it 'makes a second match when it has the right number of users' do
    allow(match_maker).to receive(:push).and_return(nil)
    2.times { match_maker.match(create(:user), 2) }
    match_maker.match(user, 2)
    match = match_maker.match(another_user, 2)
    expect(match.users).to contain_exactly(user, another_user)
  end

  it 'does not match users wanting different number of opponents' do
    match_maker.match(user, 3)
    match = match_maker.match(another_user, 2)
    expect(match).to be_nil
  end
end
