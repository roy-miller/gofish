require 'sinatra/activerecord'
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
  has_and_belongs_to_many :users, -> { order(' matches_users.id ASC') }
  has_one :winner, class_name: 'User', foreign_key: 'winner_id'
  serialize :game
  serialize :observers
  after_initialize :set_up_match # unless persisted? or if: :new_record?
  after_save :notify_observers #unless :skip_callbacks_for_test

  attr_accessor :match_users
  attr_writer :skip_callbacks_for_test

  def set_up_match
    self.game ||= make_game
    @match_users = self.users.each_with_index.map { |user, index| MatchUser.new(user: user, player: self.game.players[index]) }
    self.status ||= MatchStatus::PENDING
    self.observers ||= []
  end

  def skip_callbacks_for_test
    @skip_callbacks_for_test ||= false
  end

  def notify_observers
    self.observers.each { |observer| observer.update(self) }
  end

  def add_observer(observer)
    self.observers << observer
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

  def initial_player
    match_users.first.player
  end

  def start
    clear_messages
    self.status = MatchStatus::STARTED
    add_message("Click a card and a player to ask for cards when it's your turn")
    add_message("It's #{self.current_player.name}'s turn")
  end

  def user_for_id(user_id)
    self.users.detect { |user| user.id == user_id }
  end

  def user_for_player(player)
    match_users.detect { |match_user| match_user.player == player }.user
  end

  def match_user_for(user)
    match_users.detect { |match_user| match_user.user == user }
  end

  def player_for(user)
    match_users.detect { |match_user| match_user.user == user }.player
  end

  def opponents_for(user)
    match_users.reject { |match_user| match_user.user == user }.map(&:user)
  end

  def deck_card_count
    self.game.deck.card_count
  end

  def ask_for_cards(requestor:, recipient:, card_rank:)
    return if requestor != self.current_player
    return if over?
    clear_messages
    add_message("#{requestor.name} asked #{recipient.name} for #{card_rank}s")
    response = self.game.request_cards(player_for(requestor), player_for(recipient), card_rank)
    if response.cards_returned?
      add_message("#{requestor.name} got #{response.cards_returned.count} #{card_rank}s from #{recipient.name}")
    else
      add_message("#{self.current_player.name} went fishing")
      go_fish(self.current_player, card_rank)
    end
    add_message("It's #{self.current_player.name}'s turn")
    end_match if over?
    draw_card_for_user(self.current_player) if !over? && match_user_for(self.current_player).out_of_cards?
    #save!
    #notify_observers
  end

  def current_player
    user_for_player(self.game.current_player)
  end

  def draw_card_for_user(user)
    self.game.draw_card(player_for(user))
  end

  def go_fish(user, card_rank)
    drawn_card = self.game.draw_card(player_for(user))
    if drawn_card.rank == card_rank
      add_message("#{user.name} drew what he asked for")
    else
      move_play_to_next_user
    end
  end

  def move_play_to_next_user
    self.game.advance_play
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
    game = Game.new(self.users.each_with_index.map { |match_user, index| Player.new(index) })
    game.deal
    game
  end

  def end_match
    winner = user_for_player(self.game.winner)
    add_message("GAME OVER - #{winner.name} won!")
    self.winner_id = winner.id
  end
end
