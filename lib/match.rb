require 'sinatra/activerecord'
require 'observer'
require_relative './request.rb'
require_relative './user.rb'
require_relative './player.rb'
require_relative './game.rb'
require_relative './match_user.rb'
require_relative './robot_user.rb'

class MatchStatus
  PENDING = 'pending'
  STARTED = 'started'
end

class Match < ActiveRecord::Base
  include Observable

  has_and_belongs_to_many :users
  has_one :winner, class_name: 'User', foreign_key: 'winner_id'
  serialize :game
  after_initialize :set_up_match

  attr_accessor :match_users, :current_user

  def set_up_match
    self.messages << "Waiting for #{users.count} total players"
    @current_user = users.first
    @match_users = users.each_with_index.map { |user, index| MatchUser.new(user: user, player: Player.new(index)) }
    self.game = make_game #Game.new(self.game_serial)
  end

  def pending?
    self.status == MatchStatus::PENDING
  end

  def started?
    self.status == MatchStatus::STARTED
  end

  def add_message(message)
    self.messages << message
  end

  def clear_messages
    self.messages.clear
  end

  def over?
    self.game.over?
  end

  def initial_user
    @match_users.first.user
  end

  def most_recent_user_added
    @match_users.last.user
  end

  def start
    clear_messages
    self.status = MatchStatus::STARTED
    self.current_user = initial_user
    add_message("Click a card and a player to ask for cards when it's your turn")
    add_message("It's #{@current_user.name}'s turn")
    self.save
  end

  def user_for_id(user_id)
    self.users.detect { |user| user.id == user_id }
  end

  def user_for_player(player)
    @match_users.detect { |match_user| match_user.player == player }.user
  end

  def match_user_for(user)
    @match_users.detect { |match_user| match_user.user == user }
  end

  def player_for(user)
    @match_users.detect { |match_user| match_user.user == user }.player
  end

  def opponents_for(user)
    @match_users.reject { |match_user| match_user.user == user }.map(&:user)
  end

  def deck_card_count
    self.game.deck.card_count
  end

  def ask_for_cards(requestor:, recipient:, card_rank:)
    binding.pry
    return if requestor != @current_user
    return if over?
    clear_messages
    add_message("#{requestor.name} asked #{recipient.name} for #{card_rank}s")
    response = game.request_cards(player_for(requestor), player_for(recipient), card_rank)
    if response.cards_returned?
      add_message("#{requestor.name} got #{response.cards_returned.count} #{card_rank}s from #{recipient.name}")
    else
      add_message("#{current_user.name} went fishing")
      send_user_fishing(current_user, card_rank)
    end
    add_message("It's #{current_user.name}'s turn")
    end_match if over?
    draw_card_for_user(current_user) if !over? && match_user_for(current_user).out_of_cards?
    changed; notify_observers
    self.save
  end

  def draw_card_for_user(user)
    self.game.draw_card(player_for(user))
  end

  def send_user_fishing(user, card_rank)
    drawn_card = self.game.draw_card(player_for(user))
    if drawn_card.rank == card_rank
      add_message("#{user.name} drew what he asked for")
    else
      move_play_to_next_user
    end
  end

  def move_play_to_next_user
    current_user_index = users.find_index(@current_user)
    @current_user = users[current_user_index + 1] || users.first
    # TODO ask Ken about this infinite loop issue
    #if @current_user.has_cards?
    #  return
    #else
    #  move_play_to_next_user
    #end
  end

  def state_for(user)
    MatchPerspective.new(match: self, user: user)
  end

  private

  def make_game
    game = Game.new(@match_users.map(&:player))
    game.deal
    self.game = game
  end

  def end_match
    winner = user_for_player(self.game.winner)
    add_message("GAME OVER - #{winner.name} won!")
    self.winner_id = winner.id
  end
end
