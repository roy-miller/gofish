require 'timeout'
require_relative './request.rb'
require_relative './user.rb'
require_relative './player.rb'
require_relative './game.rb'
require_relative './match_user.rb'
require_relative './robot_match_user.rb'

class Status
  PENDING = 'pending'
  STARTED = 'started'
end

class Match
  attr_accessor :id, :opponent_count, :game, :match_users, :current_user,
                :status, :messages, :start_timeout_seconds
  CARDS_PER_PLAYER = 5
  @@matches = []

  def self.find(match_id)
    @@matches.find { |match| match.id == match_id }
  end

  def self.add_match(match)
    @@matches << match
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

  def self.add_user(id: nil, name:, opponent_count: 1)
    pending_match = @@matches.find { |match| match.status == Status::PENDING && match.opponent_count == opponent_count }
    pending_match = self.make_match(opponent_count) if pending_match.nil?
    user = User.find(id) || User.new(id: id, name: name)
    match_user = MatchUser.new(match: pending_match, user: user)
    pending_match.add_user(match_user: match_user)
    pending_match.start_or_tell_user_to_wait(match_user)
    pending_match # TODO why return the match?
  end

  def self.make_match(opponent_count)
    players = (1..opponent_count + 1).map { |index| Player.new(index) }
    game = Game.new(players)
    game.deal(cards_per_player: CARDS_PER_PLAYER)
    pending_match = Match.new(id: @@matches.count, opponent_count: opponent_count, game: game)
    self.add_match(pending_match)
    pending_match.trigger_start_timer
    pending_match
  end

  def trigger_start_timer(timeout_seconds=start_timeout_seconds)
    Thread.start {
      begin
        Timeout::timeout(timeout_seconds) {
          until @status == Status::STARTED
            # better way to wait?
          end
        }
      rescue Timeout::Error => e
        add_robots
        start
        notify_observers_of_start
      end
    }
  end

  def notify_observers_of_start
    @match_users.each { |user| user.start_playing }
  end

  def notify_observers_of_change
    @match_users.each { |user| user.match_changed }
  end

  def add_robots
    number_of_robots = (@opponent_count + 1) - @match_users.count
    (1..number_of_robots).each do |number|
      robot = RobotMatchUser.new(match: self, user: User.new(name: "robot#{number}"))
      add_user(match_user: robot)
    end
  end

  def initialize(id: 0, opponent_count: 1, game: nil, match_users: [])
    @id = id
    @opponent_count = opponent_count
    @game = game
    @match_users = match_users
    @messages = []
    @status = Status::PENDING
    @start_timeout_seconds = 5
  end

  def pending?
    @status == Status::PENDING
  end

  def started?
    @status == Status::STARTED
  end

  def broadcast(message)
    @messages << message
  end

  def clear_messages
    @messages.clear
  end

  def over?
    @game.over?
  end

  def add_user(match_user:)
    @match_users << match_user
    match_user.player = @game.players[@match_users.index(match_user)]
  end

  def start_or_tell_user_to_wait(match_user)
    if enough_users_to_start?
      start
    else
      broadcast('Waiting for players')
    end
  end

  def initial_user
    @match_users.first
  end

  def most_recent_user_added
    @match_users.last
  end

  def make_game_for(match_users:, opponent_count: 1)
    players = match_users.map.with_index { |match_user, index| Player.new(index) }
    game = Game.new(players)
    game.deal(cards_per_player: CARDS_PER_PLAYER)
    game
  end

  def enough_users_to_start?
    @match_users.count == @opponent_count + 1
  end

  def start
    clear_messages
    @status = Status::STARTED
    @current_user = initial_user
    broadcast("Click a card and a player to ask for cards when it's your turn")
    broadcast("It's #{@current_user.name}'s turn")
  end

  def user_for_player(player)
    @match_users.detect { |match_user| match_user.player.number == player.number }
  end

  # TODO get rid of this?
  def match_user_for(user_id)
    @match_users.detect { |match_user| match_user.id == user_id }
  end

  def player_for(match_user)
    @match_users.detect { |m| m.id == match_user.id }.player
  end

  def opponents_for(match_user)
    @match_users.reject { |m| m.id == match_user.id }
  end

  def deck_card_count
    @game.deck.card_count
  end

  # TODO oh, the humanity
  def ask_for_cards(requestor:, recipient:, card_rank:)
    return if requestor != @current_user
    clear_messages
    if over?
      broadcast("GAME OVER - #{winner.name} won!")
      return
    end
    broadcast("#{requestor.name} asked #{recipient.name} for #{card_rank}s")
    request = Request.new(requestor: requestor.player, recipient: recipient.player, card_rank: card_rank)
    response = send_request_to_user(request)
    if response.cards_returned?
      broadcast("#{requestor.name} got #{response.cards_returned.count} #{response.card_rank}s from #{recipient.name}")
      send_cards_to_user(@current_user, response)
    else
      broadcast("#{@current_user.name} went fishing")
      send_user_fishing(@current_user, request.card_rank)
    end
    broadcast("It's #{@current_user.name}'s turn")
    if @current_user.out_of_cards? && !@game.deck.has_cards?
      broadcast("GAME OVER - #{winner.name} won!")
      return
    end
    if @current_user.out_of_cards? && @game.deck.has_cards?
      draw_card_for_user(@current_user)
    end
    if over?
      broadcast("GAME OVER - #{winner.name} won!")
      return
    end
    notify_observers_of_change
  end

  def send_request_to_user(request)
    @game.ask_player_for_cards(player: request.recipient, request: request)
  end

  def send_cards_to_user(user, response)
    @game.give_cards_to_player(player: user.player, response: response)
  end

  def draw_card_for_user(user)
    @game.draw_card(user.player)
  end

  def send_user_fishing(user, card_rank)
    drawn_card = @game.draw_card(user.player)
    if drawn_card.rank == card_rank
      broadcast("#{user.name} drew what he asked for")
    else
      move_play_to_next_user
    end
  end

  def move_play_to_next_user
    current_user_index = @match_users.find_index(@current_user)
    @current_user = @match_users[current_user_index + 1] || @match_users.first
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
    user_for_player(@game.winner)
  end

end
