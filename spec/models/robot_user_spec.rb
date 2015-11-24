require 'spec_helper'

describe RobotUser do
  let(:user) { build(:robot_user) }
  let(:other_user) { build(:robot_user) }
  let(:match) { build(:match, users: [user, other_user]) }

  before do
    user.add_match(match)
    other_user.add_match(match)
  end

  it 'provides its name' do
    expect(user.name).to eq "robot#{user.id}"
  end

  it 'makes a play if it is his turn' do
    match.current_user = user
    match.changed
    allow(match).to receive(:ask_for_cards).and_return(nil)
    match.notify_observers
    expect(match).to have_received(:ask_for_cards).with(hash_including(requestor: user), any_args)
  end
end
