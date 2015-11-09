require_relative './match.rb'

class MatchPerspective
  attr_accessor :match_id, :you, :current_user, :initial_user, :player, :opponents,
                :deck_card_count, :status, :messages

  def index()
  end

  # TODO flatten this out more instead of shipping back match user instances
  def for(match:, user:)
    @match_id        = match.id
    @you             = user
    @current_user    = match.current_user
    @initial_user    = match.initial_user
    @player          = match.player_for(user)
    @opponents       = match.opponents_for(user)
    @deck_card_count = match.deck_card_count
    @status          = match.status
    @messages        = match.messages_for(user)
    self
  end

  def pending?
    @status == Status::PENDING
  end

end
