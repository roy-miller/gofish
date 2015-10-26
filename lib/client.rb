require 'socket'
require 'json'

class Client
  attr_accessor :unique_id, :socket, :server_address, :port

  def initialize(verbose: false, server_address: 'localhost', port: 2000)
    @server_address = server_address
    @port = port
    @verbose = verbose
  end

  def connect
    @socket = TCPSocket.open(@server_address, @port)
  end

  def run
    ask_to_play
    play_game if @unique_id
  end

  def ask_to_play
    provide_id
    response = provide_name
    @unique_id = response.match(/id: (.+)/).captures.first
  end

  def get_name
    get_user_input
    #provide_input_when_asked
  end

  def provide_id
    send_server_input("nonexistent\n")
    response = get_server_output
    puts response
  end

  def provide_name
    response = get_server_output
    puts response #enter name msg
    name = get_name
    send_server_input(name)
    response = get_server_output
    puts response
    response
  end

  def play_game(output=$stdout)
    until @socket.closed? do
      response = get_server_output
      if response
        output.puts response
        if response =~ /OVER/
          disconnect
        else
          # shouldn't this have to wait until something comes in?
          provide_input_when_asked
          # while input = provide_input_when_asked
          #   send_server_input(input)
          # end
        end
      end
    end
  end

  def disconnect
    @socket.close
  end

  def get_user_input
    gets.chomp
  end

  def provide_input_when_asked
    begin
      input = $stdin.read_nonblock(1000).chomp
      send_server_input(input)
    rescue IO::WaitReadable
      #IO.select([@socket])
      #retry
      sleep 0.1
      first = true
      retry if first
      first = false
    end
  end

  def send_server_input(input)
    puts "sent server input: #{input}" if @verbose
    @socket.puts input
  end

  def get_server_output(delay=0.1)
    sleep delay
    response = nil
    begin
      response = @socket.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      # retry logic blocks in odd ways, so assume we don't need it
      # IO.select([@socket])
      # retry
    end
    puts "got server output: #{response}" if @verbose
    response
  end

end
