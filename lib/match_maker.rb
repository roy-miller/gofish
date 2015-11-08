require_relative './user'
require_relative './player'
require_relative './game'
require_relative './match'
require_relative './match_user'

class MatchMaker
  def add_pending_user(id: nil, name:, opponent_count: 1)
    user = User.find(id) || User.new(id: id, name: name)
    match_user = MatchUser.new(user: user)
    match = Match.first_pending
    match.add_user(match_user, opponent_count)
    match
  end
end
