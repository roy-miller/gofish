require 'socket'

class MockClient
  attr_accessor :socket, :captured_output

  def connect(port=2000)
    @socket = TCPSocket.new('localhost', 2000)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @captured_output = @socket.read_nonblock(1000)
  rescue IO::WaitReadable
    @captured_output = ""
    retry
  end

  def output
    capture_output
    @captured_output
  end
end
