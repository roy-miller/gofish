require_relative './request.rb'
require_relative './user.rb'
require_relative './player.rb'
require_relative './game.rb'
require_relative './match_user.rb'

# a match manages what to say to a given user
#   that probably means having an array of messages queued up for user N
# controller can ask match for what to say to given user

class Status
  PENDING = 'pending'
  STARTED = 'started'
end

class Match
  attr_accessor :id, :game, :match_users, :current_user, :status
  CARDS_PER_PLAYER = 5
  @@matches = []

  def self.find(match_id)
    match = @@matches.find { |match| match.id = match_id }
    unless match # TODO this side effect chafes
      player1 = Player.new(1)
      player2 = Player.new(2)
      game = Game.new([player1, player2]).tap do |game|
        game.deal(cards_per_player: 5)
      end
      match_users = [
        MatchUser.new(user: User.new(name: "Player1"), player: player1),
        MatchUser.new(user: User.new(name: "Player2"), player: player2)
      ]
      match = Match.new(id: match_id, game: game, match_users: match_users)
      @@matches << match
    end
    match
  end

  # TODO this seems elbowy
  def self.find_for_user(user_id)
    found_match = nil
    @@matches.each do |match|
      found_match = match if match.match_users.select { |match_user| match_user.id == user_id }.any?
    end
    found_match
  end

  def self.matches
    @@matches
  end

  def self.matches=(value)
    @@matches = value
  end

  def self.add_match(match)
    existing = @@matches.find { |m| m.id = match.id }
    return if existing
    @@matches << match
  end

  def self.first_pending
    @@matches.find { |match| match.status == Status::PENDING }
  end

  def self.reset
    @@matches = []
  end

  def initialize(id: 0, game: nil, match_users: [])
    @id = id
    @game = game
    @match_users = match_users
    @current_user = @match_users.first
    @status = Status::PENDING
  end

  def pending?
    @status == Status::PENDING
  end

  def started?
    @status == Status::STARTED
  end

  def next_player_number
    @match_users.count + 1
  end

  def deal
    @game.deal(cards_per_player: CARDS_PER_PLAYER)
  end

  def user_names
    @match_users.map { |match_user| match_user.name }
  end

  def players
    @match_users.map(&:player)
  end

  def over?
    @game.over?
  end

  def add_user(match_user)
    match_user.player = Player.new(next_player_number)
    @match_users << match_user
    if enough_users_to_start?
      @game = make_game_for(@match_users)
      @status = Status::STARTED
    end
  end

  def enough_users_to_start?
    @match_users.count >= 2
  end

  def make_game_for(match_users)
    players = match_users.map(&:player)
    game = Game.new(players)
    game.deal(cards_per_player: CARDS_PER_PLAYER)
    game
  end

  def move_play_to_next_user
    current_user_index = @match_users.find_index(@current_user)
    next_user_to_play = @match_users[current_user_index + 1].nil? ? @match_users.first : @match_users[current_user_index + 1]
    @current_user = next_user_to_play
    @current_user
  end

  def user_with_name(name)
    @match_users.detect { |match_user| match_user.name == name }
  end

  def player_for(user_id)
    match_user = @match_users.detect { |match_user| match_user.id == user_id }
    match_user.player
  end

  def opponents_for(user_id)
    @match_users.reject { |match_user| match_user.id == user_id } #.map { |opponent| opponent.player }
  end

  def send_request_to_user(request)
    @game.ask_player_for_cards(request)
  end

  def send_cards_to_user(user, response)
    @game.give_cards_to_player(user.name, response)
  end

  def send_user_fishing(user)
    @game.draw_card(user.name)
  end

  def state
    state = ''
    match_users.each do |match_user|
      state << "#{match_user.name} has #{@game.card_count_for_player(match_user.player.number)} cards"
      state << " and these books: [ "
      state << @game.books_for_player(match_user.player.number).map { |book| "#{book.value}s" }.join(', ')
      state << " ]"
      state << "\n"
    end
    state.chomp
  end

  def state_for(match_user)
    state = ''
    state << "you have these cards: "
    state << @game.cards_for_player(match_user.id).map { |card| card.to_s }.join(', ')
    state << " and these books: [ "
    state << @game.books_for_player(match_user.id).map { |book| "#{book.value}s" }.join(', ')
    state << " ]"
    state
  end

  def winner
    winning_player = game.players.max_by(&:book_count)
    user_with_name(winning_player.name)
  end

end
