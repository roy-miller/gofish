require_relative './user'
require_relative './player'
require_relative './game'
require_relative './match'

class MatchMaker
  attr_accessor :pending_users
  CARDS_PER_PLAYER = 5

  def initialize
    @pending_users = []
  end

  def add_pending_user(id: nil, name:)
    user = User.find(id)
    user = User.new(id: id, name: name) if user.nil?
    @pending_users << user
    if @pending_users.count >= 2
      return make_match
    end
    user
  end

  private

    def make_match
      users = [@pending_users.shift, @pending_users.shift]
      game = make_game_for(users)
      match = Match.new(game: game, users: users)
      match
    end

    def make_game_for(users)
      players = users.map { |user| Player.new(user.name) }
      game = Game.new(players)
      game.deal(cards_per_player: CARDS_PER_PLAYER)
      game
    end
end
