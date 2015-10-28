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

  def handle_client(client)
    welcome_client(client)
    id = get_client_id(client) || die(client)
    pending_users << find_user_for(client, id)
    if enough_users_for_match?
      users = [pending_users.shift, pending_users.shift]
      game = make_game_for(users)
      match = make_match(game, users)
      tell_player_names(match)
      play_match(match)
    end
  end

  def welcome_client(client)
    send_output(client, 'Welcome to GoFish!')
  end

  def get_client_id(client)
    send_output(client, 'Please enter your user id, or hit Enter to create a new user ...')
    get_input_from(client) #|| die(client)
  end

  def get_input_from(delay=0.75,client)
    sleep delay
    result = nil
    begin
      result = client.read_nonblock(1000).chomp
      #puts "got input from client: #{result}" if @verbose
    rescue IO::WaitReadable
      IO.select([client]) # why does this make it work better? is it RIGHT?
      retry
    end
    #result # deserialize(result)
  end

  def die(client)
    stop_connection(client)
    Thread.kill(Thread.current)
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
    puts "starting to play" if @verbose
    match.deal
    puts "telling users initial state" if @verbose
    tell_players_initial_state(match)
    while !match.over? do
      puts "match not over, asking #{match.current_user.name} for request" if @verbose
      ask_current_user_for_request(match.current_user)
      request_info = get_input_from(match.current_user.client)
      puts "got request: #{request_info}" if @verbose
      request = create_request(match, request_info)
      puts "created request: #{request}" if @verbose
      recipient_response = send_request_to_recipient(match, request)
      puts "got response: #{recipient_response}" if @verbose
      if recipient_response.cards_returned?
        puts "response had cards, so telling everybody" if @verbose
        tell_players_originator_got_cards(match, recipient_response)
        puts "sending cards to the requestor" if @verbose
        send_response_to_originator(match, recipient_response)
        puts "telling requestor (#{recipient_response.originator.name}) state" if @verbose
        tell_originator_state(match, match.current_user)
        puts "telling recipient (#{recipient_response.recipient.name}) state" if @verbose
        tell_recipient_state(match, recipient_response.recipient)
      else
        puts "response had no cards, telling #{match.current_user.name} to go fish" if @verbose
        tell_originator_to_go_fish(match, match.current_user)
        puts "telling originator (#{recipient_response.originator.name}) state after fishing" if @verbose
        tell_originator_state(match, match.current_user)
        puts "telling recipient (#{recipient_response.recipient.name}) state after fishing" if @verbose
        tell_recipient_state(match, recipient_response.recipient)
        puts "moving to next user" if @verbose
        match.move_play_to_next_user
        puts "user is now: #{match.current_user.name}" if @verbose
      end
      puts "telling players game state" if @verbose
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
    send_output(user.client, "Ask another player for cards (enter player name and card rank, like 'bob J'):")
  end

  def create_request(match, request_info)
    username_to_ask, rank_to_ask_for = request_info.split(' ')
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
    username = get_input_from(client) || die(client)
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
