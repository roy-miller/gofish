require 'socket'

class MockServer
  attr_accessor :socket, :clients, :captured_input

  def start(port=2000)
    @server = TCPServer.new('localhost', 2000)
    @clients = []
  end

  def accept_client
    client = @server.accept
    clients << client
    client
  end

  def provide_output(client, text)
    client.puts(text)
  end

  def capture_input(delay=0.1, client)
    sleep delay
    @captured_input = client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    @captured_input = ""
    retry
  end

  def output
    capture_input
    @captured_input
  end

  def stop
    @server.close
  end
end
