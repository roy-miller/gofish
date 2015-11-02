require_relative './request.rb'
require_relative './user.rb'
require_relative './player.rb'
require_relative './game.rb'
require 'pry'

class Match
  attr_accessor :game, :users, :current_user
  CARDS_PER_PLAYER = 5
  @@matches = {}
  @@match_id = 0

  def self.find(match_id)
    # @@matches ||= {}
    # binding.pry
    match = @@matches[match_id]
    unless match
      game = Game.new([Player.new("Player1"),Player.new("Player2")]).tap do |game|
        game.deal(cards_per_player: 5)
      end
      match = Match.new(game: game, users: [User.new(name: "Player1"), User.new(name: "Player2")])
      @@matches[match_id] = match
    end
    match
  end

  def self.find_for_user(user_id)
    found_match = nil
    # binding.pry
    @@matches.each do |match_id, match|
      # puts "#{match_id}|#{match.users.count}"
      found_match = match if match.users.select { |user| user.id == user_id }.any?
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
    match_id_added = @@match_id
    @@matches[match_id_added] = match
    @@match_id += 1
    match_id_added
  end

  def self.reset
    self.matches = []
    self.match_id = 0
  end

  def initialize(game: nil, users: [])
    @game = game
    @users = users
    @current_user = @users.first
  end

  def deal
    @game.deal(cards_per_player: CARDS_PER_PLAYER)
  end

  def user_names
    @users.map(&:name)
  end

  def players
    @game.players
  end

  def over?
    @game.over?
  end

  def move_play_to_next_user
    current_user_index = @users.find_index(@current_user)
    next_user_to_play = @users[current_user_index + 1].nil? ? @users.first : @users[current_user_index + 1]
    @current_user = next_user_to_play
    @current_user
  end

  def user_with_name(name)
    matching_user = @users.detect { |user| user.name == name }
    matching_user
  end

  def player_for(user_id)
    user = @users.detect { |user| user.id == user_id }
    @game.player_for_name(user.name)
  end

  def opponents_for(user_id)
    user = @users.detect { |user| user.id == user_id }
    @game.opponents_for_player_named(user.name)
  end

  def send_request_to_user(request)
    response = @game.ask_player_for_cards(request)
    response
  end

  def send_cards_to_user(user, response)
    @game.give_cards_to_player(user.name, response)
  end

  def send_user_fishing(user)
    @game.draw_card(user.name)
  end

  def state
    # should game be doing this?
    state = ''
    users.each do |user|
      state << "#{user.name} has #{@game.card_count_for_player_named(user.name)} cards"
      state << " and these books: [ "
      state << @game.books_for_player_named(user.name).map { |book| "#{book.value}s" }.join(', ')
      state << " ]"
      state << "\n"
    end
    state.chomp
  end

  def state_for(user)
    # should game be doing this?
    state = ''
    state << "you have these cards: "
    state << @game.cards_for_player_named(user.name).map { |card| card.to_s }.join(', ')
    state << " and these books: [ "
    state << @game.books_for_player_named(user.name).map { |book| "#{book.value}s" }.join(', ')
    state << " ]"
    state
  end

  def winner
    winning_player = game.players.max_by(&:book_count)
    user_with_name(winning_player.name)
  end

end
