require 'socket'

class TestClient
  attr_accessor :unique_id, :socket, :server_address, :port

  def initialize(verbose: false, server_address: 'localhost', port: 2000)
    @server_address = server_address
    @port = port
    @verbose = verbose
  end

  def connect
    @socket = TCPSocket.open(@server_address, @port)
  end

  def show_server_output(delay=0.1)
    sleep delay
    response = nil
    begin
      response = @socket.read_nonblock(1000).chomp
      puts response
    rescue IO::WaitReadable
    end
  end

  def provide_input_when_asked
    begin
      input = $stdin.read_nonblock(1000).chomp
      send_server_input(input)
    rescue => e
    end
  end

  def send_server_input(input)
    puts "input has #{input.chars.count} characters"
    puts "sent server input: #{input}"
    @socket.write input.chomp
  end

end
