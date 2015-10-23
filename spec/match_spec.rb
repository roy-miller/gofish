require 'spec_helper'

describe Match do
  let(:match) { Match.new }

  it 'is over if its game is over' do
    game = double("game")
    allow(game).to receive(:over?) { true }
    match.game = game
    expect(match.over?).to be_truthy
  end

  it 'tells its user names' do
    user1 = User.new('user1')
    user2 = User.new('user2')
    match.users << user1
    match.users << user2
    expect(match.user_names).to match_array ['user1', 'user2']
  end

end
