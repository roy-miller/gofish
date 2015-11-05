require_relative './user'

class MatchUser
  attr_accessor :user, :player

  def initialize(user:, player: nil)
    @user = user
    @player = player
  end

  def id
    @user.id
  end

  def name
    @user.name
  end


end
