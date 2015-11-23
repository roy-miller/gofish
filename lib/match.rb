require 'observer'
require_relative './request.rb'
require_relative './user.rb'
require_relative './player.rb'
require_relative './game.rb'
require_relative './match_user.rb'
require_relative './robot_match_user.rb'

class MatchStatus
  PENDING = 'pending'
  STARTED = 'started'
end

class Match
  include Observable

  attr_accessor :id, :game, :users, :match_users, :current_user, :status, :messages
  CARDS_PER_PLAYER = 5
  @@matches = []

  def self.find(match_id)
    @@matches.find { |match| match.id == match_id }
  end

  def self.matches
    @@matches
  end

  def self.matches=(value)
    @@matches = value
  end

  def self.reset
    @@matches = []
  end

  def initialize(users=[], id: 0)
    @id = id
    @messages = []
    @messages << "Waiting for #{users.count} total players"
    @status = MatchStatus::PENDING
    @users = users
    @users.each { |user| user.add_match(self) }
    # TODO are match_users really necessary?
    @match_users = users.each_with_index.map { |user, index| MatchUser.new(user: user, player: Player.new(index)) }
    @game = make_game
    @current_user = users.first
    save
  end

  def save
    @@matches << self
  end

  def pending?
    @status == MatchStatus::PENDING
  end

  def started?
    @status == MatchStatus::STARTED
  end

  def add_message(message)
    @messages << message
  end

  def clear_messages
    @messages.clear
  end

  def over?
    @game.over?
  end

  def initial_user
    @match_users.first.user
  end

  def most_recent_user_added
    @match_users.last.user
  end

  def start
    clear_messages
    @status = MatchStatus::STARTED
    @current_user = initial_user
    add_message("Click a card and a player to ask for cards when it's your turn")
    add_message("It's #{@current_user.name}'s turn")
  end

  def user_for_id(user_id)
    @users.detect { |user| user.id == user_id }
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
    game.deck.card_count
  end

  def ask_for_cards(requestor:, recipient:, card_rank:)
    return if requestor != @current_user
    clear_messages
    if over?
      add_message("GAME OVER - #{winner.name} won!")
      return
    end
    add_message("#{requestor.name} asked #{recipient.name} for #{card_rank}s")
    request = Request.new(requestor: player_for(requestor), recipient: player_for(recipient), card_rank: card_rank)
    response = send_request_to_user(request)
    if response.cards_returned?
      add_message("#{requestor.name} got #{response.cards_returned.count} #{response.card_rank}s from #{recipient.name}")
      send_cards_to_user(current_user, response)
    else
      add_message("#{current_user.name} went fishing")
      send_user_fishing(current_user, request.card_rank)
    end
    add_message("It's #{current_user.name}'s turn")
    if match_user_for(current_user).out_of_cards? && !game.deck.has_cards?
      add_message("GAME OVER - #{winner.name} won!")
      return
    end
    if match_user_for(current_user).out_of_cards? && @game.deck.has_cards?
      draw_card_for_user(current_user)
    end
    if over?
      add_message("GAME OVER - #{winner.name} won!")
      return
    end
    changed; notify_observers('match_change_event')
  end

  def send_request_to_user(request)
    game.ask_player_for_cards(player: request.recipient, request: request)
  end

  def send_cards_to_user(user, response)
    game.give_cards_to_player(player: player_for(user), response: response)
  end

  def draw_card_for_user(user)
    game.draw_card(player_for(user))
  end

  def send_user_fishing(user, card_rank)
    drawn_card = game.draw_card(player_for(user))
    if drawn_card.rank == card_rank
      add_message("#{user.name} drew what he asked for")
    else
      move_play_to_next_user
    end
  end

  def move_play_to_next_user
    current_user_index = users.find_index(@current_user)
    @current_user = users[current_user_index + 1] || users.first
    # TODO ask Ken about this one
    #if @current_user.has_cards?
    #  return
    #else
    #  move_play_to_next_user
    #end
  end

  def state_for(user)
    MatchPerspective.new(match: self, user: user)
  end

  def winner
    user_for_player(game.winner)
  end

  private

  def make_game
    game = Game.new(@match_users.map(&:player))
    game.deal(cards_per_player: CARDS_PER_PLAYER)
    game
  end
end
