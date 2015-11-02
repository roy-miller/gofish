require_relative './user.rb'
require_relative './player.rb'

class UserPlayerPair
  attr_accessor :user, :player

  def initialize(user:, player:)
    @user = user
    @player = player
  end

end
