require 'json'
require_relative './match.rb'

class MatchPerspective
  attr_accessor :match_id, :you, :current_user, :initial_user, :player, :opponents,
                :deck_card_count, :status, :messages

  # TODO flatten this out more instead of shipping back match user instances?
  def initialize(match:, user:)
    @match           = match
    @match_id        = match.id
    @you             = user
    @current_user    = match.current_user
    @initial_user    = match.initial_user
    @player          = match.player_for(user)
    @opponents       = match.opponents_for(user)
    @deck_card_count = match.deck_card_count
    @status          = match.status
    @messages        = match.messages
  end

  def pending?
    @status == MatchStatus::PENDING
  end

  def started?
    @status == MatchStatus::STARTED
  end

  def hash
    hash = {}
    hash[:status] = pending? ? 'pending' : 'started'
    hash[:name] = @you.name
    hash[:messages] = @messages
    hash[:book_count] = @player.books.count
    hash[:deck_card_count] = @deck_card_count
    hash[:cards] = @player.hand.map { |card| { rank: card.rank, suit: card.suit } }
    hash[:opponents] = @opponents.map do |opponent|
      {
        name: opponent.name,
        card_count: @match.player_for(opponent).card_count,
        book_count: @match.player_for(opponent).book_count
      }
    end
    hash
  end

  def to_json
    hash.to_json
  end

end
