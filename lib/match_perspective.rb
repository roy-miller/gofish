require_relative './match.rb'

class MatchPerspective
  attr_accessor :you, :current_user, :initial_user, :player, :opponents,
                :deck_card_count, :status, :messages

  def index()
  end

  def for(match:, with:)
    @you             = with
    @current_user    = match.current_user
    @initial_user    = match.initial_user
    @player          = match.player_for(with)
    @opponents       = match.opponents_for(with)
    @deck_card_count = match.deck_card_count
    @status          = match.status
    @messages        = match.messages_for(with)
    self
  end

  def pending?
    @status == Status::PENDING
  end

end
