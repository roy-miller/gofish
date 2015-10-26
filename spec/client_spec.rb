require 'spec_helper'

def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end

def provide_stdin(input='', &blk)
	old = $stdin
	$stdin = StringIO.new
	$stdin << input
	$stdin.rewind
	blk.call
ensure
	$stdin = old
end

def provide_input(text)
  @client.socket.puts(text)
end

describe Client do
  let(:server) { MockServer.new }
  let(:client) { Client.new }

  before do
    server.start
    client.connect
    server.accept_client
  end

  after do
    server.stop
  end

  it 'connects to listening server' do
    expect(client.socket.closed?).to be false
  end

  it 'receives output from server' do
    server.provide_output(server.clients.first, 'server output')
    expect(client.get_server_output).to eq 'server output'
  end

  it 'provides input when asked' do
    provide_stdin("Roy\n") do
      client.provide_input_when_asked
    end
    expect(server.capture_input(server.clients.first)).to eq 'Roy'
  end

  it 'disconnects' do
    client.disconnect
    expect(client.socket.closed?).to be true
  end
end
