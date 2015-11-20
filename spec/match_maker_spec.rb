require 'spec_helper'

describe MatchMaker do
  let(:match_maker) { MatchMaker.new }
  let(:user) { User.new(name: "user1") }
  let(:another_user) { User.new(name: "user2") }

  it 'does not make a match when it does not have the right number of users' do
    expect(match_maker.match(user, 2)).to be_nil
  end

  it 'makes a match when it has the right number of users' do
    match_maker.match(user, 2)
    match = match_maker.match(another_user, 2)
    expect(match).to_not be_nil
    expect(match.users).to contain_exactly(user, another_user)
  end

  it 'does not match users wanting different number of opponents' do
    match_maker.match(user, 3)
    match = match_maker.match(another_user, 2)
    expect(match).to be_nil
  end
end
