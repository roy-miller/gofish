require 'socket'
require_relative './game.rb'
require_relative './player.rb'
require_relative './user.rb'
require_relative './match.rb'

class Server

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
    until @server.closed? do
      Thread.start(accept_client) { |client| handle_client(client) }
    end
  end

  def accept_client
    client = @server.accept
    clients << client
    welcome_client(client)
    client
  end

  def welcome_client(client)
    send_output(client, 'Welcome to GoFish!')
  end

  def handle_client(client)
    id = get_client_id(client)
    @pending_users << set_user_client(client, id)
    puts "@pending_users now: #{@pending_users.count}"
    if users_ready?
      game = make_game
      match = make_match(game, users)
      tell_player_names(match)
      play_match(match)
    end
  end

  def tell_player_names(match)
    names = match.user_names.join(", ")
    match.users.each { |user| send_output(user.client, "Who's playing: #{names}") }
  end

  def make_game
    game = Game.new
    game.add_player(Player.new(@pending_users.shift.name))
    game.add_player(Player.new(@pending_users.shift.name))
    games << game
    game
  end

  def make_match(game, users)
    match = Match.new(game, users)
    match
  end

  def play_match
    match.deal
    while !match.over? do
      prompt_next_user_for_request(match)
    end
    congratulate_winner(match)
  end

  def prompt_next_user_for_request
  end

  def get_client_id(client)
    get_input_from(client) || die(socket)
  end

  def get_input_from(client)
    result = nil
    begin
      result = client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
      retry
    end
    puts "got input from client: #{result}"
    result # deserialize(result)
  end

  def die(client)
    stop_connection(client)
    Thread.kill(Thread.current)
  end

  def set_user_client(client, id)
    user = User.find(id)
    if user
      send_output(client, "Welcome back, #{user.name}!")
    else
      username = get_name(client)
      user = User.new(client)
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

  def users_ready?
    @pending_users.count >= 2
  end

  def users
    [@pending_users.shift, @pending_users.shift]
  end

  def send_output(client, message)
    puts "sending output: #{client}, #{message}"
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
