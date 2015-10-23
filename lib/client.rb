require 'socket'
require 'json'

class Client
  attr_accessor :unique_id, :socket, :server_address, :port

  def initialize(server_address: 'localhost', port: 2000)
    @server_address = server_address
    @port = port
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
    puts "ask_to_play response: #{response}"
    @unique_id = response.match(/id: (.+)/).captures.first
  end

  def get_name
    get_user_input
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
    while response = get_server_output
      output.puts response
      if response[:message] =~ /OVER/
        disconnect
      else
        while input = get_user_input
          play_next_round
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

  def send_server_input(input)
    puts "sent server input: #{input}"
    @socket.puts input
  end

  def get_server_output
    response_json_string = nil
    begin
      response = @socket.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([@socket])
      retry
    end
    puts "got server output: #{response}"
    response
  end

end
