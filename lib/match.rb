require_relative './request.rb'
require_relative './user.rb'
require_relative './player.rb'
require_relative './game.rb'
require_relative './match_user.rb'

class Status
  PENDING = 'pending'
  STARTED = 'started'
end

class Match
  attr_accessor :id, :game, :match_users, :current_user, :status, :messages
  CARDS_PER_PLAYER = 5
  @@matches = []

  def self.find(match_id)
    match = @@matches.find { |match| match.id = match_id }
    unless match # TODO this side effect for testing chafes
      player1 = Player.new(1)
      player2 = Player.new(2)
      game = Game.new([player1, player2]).tap do |game|
        game.deal(cards_per_player: 5)
      end
      match_users = [
        MatchUser.new(user: User.new(id: 1, name: "Player1"), player: player1),
        MatchUser.new(user: User.new(id: 2, name: "Player2"), player: player2)
      ]
      match = Match.new(id: match_id, game: game, match_users: match_users)
      match_users.each { |match_user| match.messages[match_user] = [] }
      @@matches << match
    end
    match
  end

  # TODO this seems elbowy
  def self.find_for_user_id(user_id)
    found_match = nil
    @@matches.each do |match|
      found_match = match if match.match_users.select { |match_user| match_user.id == user_id }.any?
    end
    found_match
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

  def self.add_user(id: nil, name:, opponent_count: 1)
    user = User.find(id) || User.new(id: id, name: name)
    match_user = MatchUser.new(user: user)
    pending_match = @@matches.find { |match| match.status == Status::PENDING }
    if pending_match.nil?
      players = (1..opponent_count + 1).map { |index| Player.new(index) }
      game = Game.new(players)
      game.deal(cards_per_player: CARDS_PER_PLAYER)
      pending_match = Match.new(id: @@matches.count, game: game)
      self.add_match(pending_match)
    end
    pending_match.add_user(match_user: match_user, opponent_count: opponent_count)
    pending_match # TODO why return the match?
  end

  def self.reset
    @@matches = []
  end

  def initialize(id: 0, game: nil, match_users: [])
    @id = id
    @game = game
    @match_users = match_users
    @messages = {}
    @status = Status::PENDING
  end

  def pending?
    @status == Status::PENDING
  end

  def started?
    @status == Status::STARTED
  end

  def inform_user(match_user, message:)
    @messages[match_user] << message
  end

  def broadcast(message)
    @match_users.each { |match_user| inform_user(match_user, message: message) }
  end

  # TODO should a match_user know his own messages?
  def messages_for(match_user)
    messages = []
    until @messages[match_user].empty?
      messages << @messages[match_user].shift
    end
    puts "LEFTOVER MESSAGES: #{@messages[match_user]}" if !@messages[match_user].empty?
    messages
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

  def add_user(match_user:, opponent_count: 1)
    @match_users << match_user
    @messages[match_user] = []
    match_user.player = @game.players[@match_users.index(match_user)]
    if enough_users_to_start?
      start
    else
      inform_user(match_user, message: 'Waiting for opponents for you')
    end
  end

  def initial_user
    @match_users.first
  end

  def make_game_for(match_users:, opponent_count: 1)
    players = match_users.map.with_index { |match_user, index| Player.new(index) }
    game = Game.new(players)
    game.deal(cards_per_player: CARDS_PER_PLAYER)
    game
  end

  def enough_users_to_start?
    @match_users.count >= 2
  end

  def start
    @status = Status::STARTED
    @current_user = initial_user
    inform_user(initial_user, message: 'Ask another player for cards by clicking a card in your hand and then the opponent name')
    opponents_for(initial_user).each do |user|
      inform_user(user, message: 'Wait for another player to ask you for cards')
    end
  end

  def user_with_name(name)
    @match_users.detect { |match_user| match_user.name == name }
  end

  def user_for_player(player)
    @match_users.detect { |match_user| match_user.player.number == player.number }
  end

  # TODO change parameter to object instead of id?
  def match_user_for(user_id)
    @match_users.detect { |match_user| match_user.id == user_id }
  end

  def player_for(match_user)
    match_user = @match_users.detect { |m| m.id == match_user.id }
    match_user.player
  end

  def opponents_for(match_user)
    @match_users.reject { |m| m.id == match_user.id }
  end

  def deck_card_count
    @game.deck.card_count
  end

  # TODO handle game over
  def ask_for_cards(requestor_id:, recipient_id:, card_rank:)
    if over?
      broadcast("GAME OVER - #{winner.name} won!")
      return
    end
    originator = match_user_for(requestor_id)
    recipient = match_user_for(recipient_id)
    request = Request.new(originator: originator, recipient: recipient, card_rank: card_rank)
    broadcast("#{request.originator.name} asked #{request.recipient.name} for #{request.card_rank}s")
    response = send_request_to_user(request)
    if response.cards_returned?
      broadcast("#{response.originator.name} got #{response.cards_returned.count} #{response.card_rank}s from #{response.recipient.name}")
      send_cards_to_user(@current_user, response)
    else
      broadcast("#{@current_user.name} went fishing")
      send_user_fishing(@current_user, request.card_rank)
    end
    broadcast("It's #{@current_user.name}'s turn")
    inform_user(@current_user, message: "Ask another player for cards by clicking a card in your hand and then the opponent name")
  end

  def send_request_to_user(request)
    # TODO ask game for player, not number
    recipient = match_user_for(request.recipient.id)
    @game.ask_player_for_cards(player_number: recipient.player.number, request: request)
  end

  def send_cards_to_user(user, response)
    originator = match_user_for(response.originator.id)
    @game.give_cards_to_player(player_number: originator.player.number, response: response)
  end

  def send_user_fishing(user, card_rank)
    player = match_user_for(user.id).player
    card_drawn = @game.draw_card(player)
    if card_drawn.rank == card_rank
      broadcast("#{user.name} drew what he asked for")
    else
      move_play_to_next_user
    end
  end

  def move_play_to_next_user
    current_user_index = @match_users.find_index(@current_user)
    potential_next = @match_users[current_user_index + 1]
    potential_next = @match_users.first if potential_next.nil? # wrap
    potential_next.has_cards? ? @current_user = potential_next : move_play_to_next_user
  end

  # TODO don't make this formatted strings
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

  # TODO don't make this formatted strings
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
    user_for_player(winning_player)
  end

end
