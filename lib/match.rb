class Match
  attr_accessor :game, :users

  def users
    @users ||= []
  end

  def deal
    @game.deal(5)
  end

  def user_names
    users.map(&:name)
  end

  def over?
    game.over?
  end

end
