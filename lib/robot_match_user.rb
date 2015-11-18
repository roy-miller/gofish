require_relative './match_user'

class RobotMatchUser < MatchUser
  def start_playing
  end

  def match_changed
    if @match.current_user == self
      recipient = @match.match_users.select { |user| user.id != @id }.sample
      #@match.ask_for_cards(requestor: self, recipient: recipient, card_rank: @player.hand.sample.rank)
    end
  end
end
