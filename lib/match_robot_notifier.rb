# require_relative './robot_user'
#
# class MatchRobotNotifier
#   attr_reader :match, :think_time
#
#   def initialize(think_time=0)
#     @think_time = think_time
#   end
#
#   def observe_match(match)
#     @match = match
#     match.add_observer(self)
#   end
#
#   def update(*args)
#     match.users.each do |user|
#       if (user.is_a?(RobotUser) && match.current_player == user)
#         make_request(user)
#       end
#     end
#   end
#
#   def make_request(user)
#     contemplate_before {
#       match.ask_for_cards(requestor: user, recipient: pick_opponent(user), card_rank: pick_rank(user))
#     }
#   end
#
#   def player(user)
#     match.player_for(user)
#   end
#
#   protected
#
#   def opponents(user)
#     match.opponents_for(user)
#   end
#
#   def pick_opponent(user)
#     opponents(user).sample
#   end
#
#   def pick_rank(user)
#     player(user).hand.sample.rank
#   end
#
#   def contemplate_before
#     if think_time > 0
#       Thread.start do
#         sleep(think_time)
#         yield
#       end
#     else
#       yield
#     end
#   end
#
# end
