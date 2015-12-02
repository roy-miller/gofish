# require 'spec_helper'
#
# describe MatchRobotNotifier do
#   let(:robot) { build(:robot_user) }
#   let(:human) { build(:user) }
#   let(:match) { create(:match, users: [human, robot]) }
#   let(:robot_notifier) { MatchRobotNotifier.new }
#
#   before do
#     robot_notifier.observe_match(match)
#   end
#
#   it 'updates subscribers when match updates' do
#     expect(robot_notifier).to receive(:update)
#     match.notify_observers
#   end
#
#   it "plays for a robot if it is that robot's turn" do
#     match.game.current_player = match.game.players.last
#     allow(match).to receive(:ask_for_cards).and_return(nil)
#     match.notify_observers
#     expected_requestor = match.user_for_player(match.game.current_player)
#     expect(match).to have_received(:ask_for_cards).once.with(hash_including(requestor: expected_requestor), any_args)
#   end
# end
