require 'json'
require_relative './match.rb'

class MatchPerspective
  attr_accessor :match_id, :user, :player, :opponents, :deck_card_count,
                :status, :messages

  def initialize(match:, user:)
    @match            = match
    @match_id         = match.id
    @user             = user
    @player           = match.player_for(user)
    @opponents        = match.opponents_for(user).map { |opponent|
                          player = match.player_for(opponent)
                          { id: opponent.id, name: opponent.name, card_count: player.card_count, book_count: player.book_count }
                        }
    @deck_card_count  = match.deck_card_count
    @status           = match.status
    @messages         = match.messages
  end

  def pending?
    @status == MatchStatus::PENDING
  end

  def started?
    @status == MatchStatus::STARTED
  end

  def to_hash
    hash = {}
    hash[:status] = pending? ? MatchStatus::PENDING : MatchStatus::STARTED
    hash[:name] = @user.name
    hash[:messages] = @messages
    hash[:book_count] = @player.book_count
    hash[:deck_card_count] = @deck_card_count
    hash[:cards] = @player.hand.map { |card| { rank: card.rank, suit: card.suit } }
    hash[:opponents] = @opponents
    hash
  end

  def to_json
    to_hash.to_json
  end

end
