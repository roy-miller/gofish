require 'spec_helper'

describe RobotUser do
  let(:user) { RobotUser.new }
  let(:other_user) { RobotUser.new }
  let(:match) { build(:match, users: [user, other_user]) }

  before do
    user.add_match(match)
    other_user.add_match(match)
  end

  it 'makes a play if it is his turn' do
    match.current_user = user
    match.changed
    allow(match).to receive(:ask_for_cards).and_return(nil)
    match.notify_observers('changed')
    expect(match).to have_received(:ask_for_cards).with(hash_including(requestor: user), any_args)
  end
end
