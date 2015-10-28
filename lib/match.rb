require_relative './request.rb'

class Match
  attr_accessor :game, :users, :current_user
  CARDS_PER_PLAYER = 5

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
    matching_user = @users.select { |user| user.name == name }.first
    matching_user
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
