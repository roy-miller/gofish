require_relative 'lib/client.rb'
require_relative 'test_client.rb'

client = TestClient.new
client.connect
until client.socket.closed? do
  client.show_server_output
  client.provide_input_when_asked
end
