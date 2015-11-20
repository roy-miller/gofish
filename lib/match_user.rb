require 'pusher'
require_relative './user'

class MatchUser
  attr_accessor :match, :user, :player, :player_channel

  def initialize(match: nil, user:, player: nil)
    @match = match
    @user = user
    @player = player
    @player_channel = "player_channel_#{@match.id}_#{@user.id}"
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

  def start_playing
    Pusher.trigger(@player_channel, 'match_start_event', { message: 'match started' })
  end

  def match_changed
    Pusher.trigger(@player_channel, 'match_change_event', { message: 'match changed' })
  end
end
