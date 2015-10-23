require 'socket'

class MockServer
  attr_accessor :socket, :clients, :captured_input

  def start(port=2000)
    @socket = TCPServer.new('localhost', 2000)
  end

  def accept
    client = @server.accept
    clients << client
    provide_output("welcome message")
    client
  end

  def provide_output(text)
    @socket.puts(text)
  end

  def capture_input(delay=0.1)
    sleep(delay)
    @captured_input = @socket.read_nonblock(1000)
  rescue IO::WaitReadable
    @captured_input = ""
    retry
  end

  def output
    capture_input
    @captured_input
  end
end
