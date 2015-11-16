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
  attr_accessor :id, :opponent_count, :game, :match_users, :current_user,
                :status, :messages
  CARDS_PER_PLAYER = 5
  @@matches = []

  def self.find(match_id)
    match = @@matches.find { |match| match.id == match_id }
    match = self.create_default_match(match_id) unless match
    match
  end

  def self.create_default_match(match_id)
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
    #puts "\nuser for match_user: #{user.inspect}"
    match_user = MatchUser.new(user: user)
    pending_match = @@matches.find { |match| match.status == Status::PENDING && match.opponent_count == opponent_count }
    pending_match = self.make_match(opponent_count) if pending_match.nil?
    pending_match.add_user(match_user: match_user, opponent_count: opponent_count)
    pending_match.start_or_tell_user_to_wait(match_user)
    #puts "added match_user, now have #{Match.matches.first.match_users.count}"
    #puts "\n"
    pending_match # TODO why return the match?
  end

  def self.make_match(opponent_count)
    players = (1..opponent_count + 1).map { |index| Player.new(index) }
    game = Game.new(players)
    game.deal(cards_per_player: CARDS_PER_PLAYER)
    pending_match = Match.new(id: @@matches.count, opponent_count: opponent_count, game: game)
    self.add_match(pending_match)
    pending_match
  end

  def self.reset
    @@matches = []
  end

  def initialize(id: 0, opponent_count: 1, game: nil, match_users: [])
    @id = id
    @opponent_count = opponent_count
    @game = game
    @match_users = match_users
    @messages = {}
    @status = Status::PENDING
  end

  # TODO don't need both of these
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

  # TODO should there even be a queue of messages for each user?
  def messages_for(match_user)
    messages = []
    until @messages[match_user].empty?
      messages << @messages[match_user].shift
    end
    messages
  end

  def over?
    @game.over?
  end

  def add_user(match_user:, opponent_count: 1)
    @match_users << match_user
    @messages[match_user] = []
    match_user.player = @game.players[@match_users.index(match_user)]
  end

  def start_or_tell_user_to_wait(match_user)
    if enough_users_to_start?
      start
    else
      inform_user(match_user, message: 'Waiting for players')
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
    match_user = @match_users.detect { |m| m.id == match_user.id }
    match_user.player
  end

  def opponents_for(match_user)
    @match_users.reject { |m| m.id == match_user.id }
  end

  def deck_card_count
    @game.deck.card_count
  end

  # TODO oh, the humanity
  def ask_for_cards(requestor:, recipient:, card_rank:)
    if requestor != @current_user
      # TODO need this?
      inform_user(requestor, message: "It's not your turn, it's #{@current_user.name}'s")
      return
    end
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
    card_drawn = @game.draw_card(user.player)
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
    @current_user = potential_next
  end

  def state_for(user)
    MatchPerspective.new(match: self, user: user)
  end

  def winner
    user_for_player(@game.winner)
  end

end
