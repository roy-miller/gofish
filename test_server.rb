require 'socket'

class TestServer

  def initialize(verbose: false)
    @verbose = verbose
  end

  def clients
    @clients ||= []
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
    while response = get_input_from(client)
      puts "got from client: #{response}, " +
           "empty? #{response.empty?}, " +
           "newline? #{response =~ /\n/ ? true : false}, " +
           "whitespace? #{response =~ /\s+/ ? true : false}"
      send_output(client, "got your input: #{response}")
    end
  end

  def welcome_client(client)
    send_output(client, "client connected")
  end

  def get_input_from(delay=0.1,client)
    sleep delay
    result = nil
    begin
      result = client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      # IO.select([client])
      retry
    end
    result # deserialize(result)
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
