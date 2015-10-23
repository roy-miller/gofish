require 'spec_helper'

def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end

def provide_input(text)
  @client.socket.puts(text)
end

describe Client do
  before do
    @server = Server.new
    @server.start
    @client = Client.new
    @client.connect
    @server.accept_client
    response = @client.get_server_output
  end
  after do
    @server.stop
  end

  it 'connects to server and gets unique id' do
    @server.send_output(@server.clients.first, "User created with id: 123")
    @client.ask_to_play
    @server.get_input_from(@server.clients.first)
    expect(@client.socket.closed?).to be false
    expect(@client.unique_id).not_to eq 123
  end

  it 'sends user name to server' do
    @client.provide_name('username')
    result = @server.get_input_from(@server.clients.first)
    expect(result).to match /username/
  end
end
