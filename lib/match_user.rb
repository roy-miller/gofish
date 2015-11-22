require_relative './user'
require_relative './player'

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

  def has_cards?
    !@player.out_of_cards?
  end

  def out_of_cards?
    @player.out_of_cards?
  end
end
