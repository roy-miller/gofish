require 'socket'
require_relative './game.rb'
require_relative './player.rb'
require_relative './user.rb'
require_relative './match.rb'
require_relative './request.rb'

class Server

  def initialize(verbose: false)
    @verbose = verbose
  end

  def pending_users
    @pending_users ||= []
  end

  def clients
    @clients ||= []
  end

  def games
    @games ||= []
  end

  def start(port=2000)
    @server = TCPServer.new(port)
    self
  end

  def run
    puts "server running ..."
    until @server.closed? do
      Thread.start(accept_client) { |client| handle_client(client) }
    end
  end

  def accept_client
    client = @server.accept
    clients << client
    client
  end

  def welcome_client(client)
    send_output(client, 'Welcome to GoFish!')
  end

  def handle_client(client)
    welcome_client(client)
    id = get_client_id(client)
    pending_users << find_user_for(client, id)
    if enough_users_for_match?
      users = [pending_users.shift, pending_users.shift]
      game = make_game_for(users)
      match = make_match(game, users)
      tell_player_names(match)
      play_match(match)
    end
  end

  def tell_player_names(match)
    names = match.user_names
    names = names.join(', ')
    match.users.each { |user| send_output(user.client, "The players are: #{names}") }
  end

  def make_game_for(users)
    players = users.map { |user| Player.new(user.name) }
    game = Game.new(players)
    games << game
    game
  end

  def make_match(game, users)
    match = Match.new(game: game, users: users)
    match
  end

  def play_match(match)
    puts "starting to play"
    match.deal
    puts "telling users initial state"
    tell_players_initial_state(match)
    while !match.over? do
      puts "match not over, asking #{match.current_user.name} for request"
      request_info = ask_current_user_for_request(match.current_user)
      puts "got request: #{request_info}"
      request = create_request(match, request_info)
      puts "created request: #{request}"
      recipient_response = send_request_to_recipient(match, request)
      puts "got response: #{recipient_response}"
      if recipient_response.cards_returned?
        puts "response had cards, so telling everybody"
        tell_players_originator_got_cards(match, recipient_response)
        puts "sending cards to the requestor"
        send_response_to_originator(match, recipient_response)
        puts "telling requestor (#{recipient_response.originator.name}) state"
        tell_originator_state(match, match.current_user)
        puts "telling recipient (#{recipient_response.recipient.name}) state"
        tell_recipient_state(match, recipient_response.recipient)
      else
        puts "response had no cards, telling #{match.current_user.name} to go fish"
        tell_originator_to_go_fish(match, match.current_user)
        puts "telling originator (#{recipient_response.originator.name}) state after fishing"
        tell_originator_state(match, match.current_user)
        puts "telling recipient (#{recipient_response.recipient.name}) state after fishing"
        tell_recipient_state(match, recipient_response.recipient)
        puts "moving to next user"
        match.move_play_to_next_user
        puts "user is now: #{match.current_user.name}"
      end
      puts "telling players game state"
      tell_players_game_state(match)
    end
    congratulate_winner(match)
  end

  def congratulate_winner(match)
    winner = match.winner
    message = "#{winner.name} won!\nHere's where things ended up ...\n#{match.state}"
    send_output_to_all_users(match, message)
  end

  def ask_current_user_for_request(user)
    send_output(user.client, "\nAsk another player for cards (enter player name and card rank, like 'bob J'):")
    request_info = get_input_from(user.client)
    request_info
  end

  def create_request(match, request_info)
    tokens = request_info.split(' ')
    username_to_ask = tokens.first
    rank_to_ask_for = tokens.last
    recipient = match.user_with_name(username_to_ask)
    Request.new(originator: match.current_user, recipient: recipient, card_rank: rank_to_ask_for)
  end

  def send_request_to_recipient(match, request)
    tell_players_about_request(match, request)
    response = match.send_request_to_user(request)
    response
  end

  def tell_players_initial_state(match)
    match.users.each do |user|
      state = match.state_for(user)
      send_output(user.client, state)
    end
  end

  def tell_players_originator_got_cards(match, response)
    message = "#{response.originator.name} got #{response.cards_returned.count} #{response.card_rank}s from #{response.recipient.name}"
    send_output_to_all_users(match, message)
  end

  def tell_players_about_request(match, request)
    message = "#{request.originator.name} asked #{request.recipient.name} for #{request.card_rank}s"
    send_output_to_all_users(match, message)
  end

  def send_response_to_originator(match, response)
    match.send_cards_to_user(match.current_user, response)
  end

  def tell_originator_state(match, user)
    state = match.state_for(user)
    send_output(user.client, state)
  end

  def tell_recipient_state(match, user)
    state = match.state_for(user)
    send_output(user.client, state)
  end

  def tell_originator_to_go_fish(match, user)
    message = "#{user.name} went fishing"
    send_output_to_all_users(match, message)
    match.send_user_fishing(user)
  end

  def tell_players_game_state(match)
    message = match.state
    send_output_to_all_users(match, message)
  end

  def send_output_to_all_users(match, output)
    match.users.each do |user|
      send_output(user.client, output)
    end
  end

  def get_client_id(client)
    get_input_from(client) || die(client)
  end

  def get_input_from(delay=0.1,client)
    sleep delay
    result = nil
    begin
      result = client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
      retry
      # sleep 1
      # first = true
      # retry if first
      # first = false
    end
    puts "got input from client: #{result}" if @verbose
    result # deserialize(result)
  end

  def die(client)
    stop_connection(client)
    Thread.kill(Thread.current)
  end

  def find_user_for(client, id)
    user = User.find(id)
    if user
      send_output(client, "Welcome back, #{user.name}!")
    else
      username = get_name(client)
      user = User.new(name: username)
      send_output(client, "User created with id: #{user.id}")
    end
    user.client = client
    user
  end

  def get_name(client)
    send_output(client, 'Type your name and hit Enter:')
    username = get_input_from(client)
    username
  end

  def enough_users_for_match?
    @pending_users.count >= 2
  end

  def users
    [@pending_users.shift, @pending_users.shift]
  end

  def send_output(client, message)
    puts "sending output: #{client}, #{message}" if @verbose
    client.puts message
  end

  def stop_connection(client)
    client.close unless client.closed?
    @clients.delete(client)
  end

  def stop
    @server.close unless @server.closed?
  end

end
