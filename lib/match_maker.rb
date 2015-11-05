require_relative './user'
require_relative './player'
require_relative './game'
require_relative './match'
require_relative './match_user'

class MatchMaker
  def add_pending_user(id: nil, name:)
    user = User.find(id) || User.new(id: id, name: name)
    match_user = MatchUser.new(user: user)
    match = Match.first_pending || Match.new
    match.add_user(match_user)
    Match.add_match(match)
    match
  end
end
