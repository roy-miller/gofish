require 'spec_helper'

describe RobotUser do
  let(:user) { create(:robot_user) }

  it 'provides its name' do
    expect(user.name).to eq "robot#{user.id}"
  end

  context 'with match' do
    let(:other_user) { create(:robot_user) }
    let(:match) { create(:match, users: [user, other_user]) }

    before do
      user.observe_match(match)
      other_user.observe_match(match)
    end

    it 'makes a play if it is his turn' do
      match.game.current_player = match.game.players.first
      allow(user).to receive(:active_match).and_return(match)
      allow(match).to receive(:ask_for_cards).and_return(nil)
      match.notify_observers
      expected_requestor = match.user_for_player(match.game.current_player)
      expect(match).to have_received(:ask_for_cards).once.with(hash_including(requestor: expected_requestor), any_args)
    end
  end
end
