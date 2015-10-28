require_relative 'lib/client.rb'
require_relative 'test_client.rb'

client = Client.new(verbose: false)
client.connect
#client.run
until client.socket.closed? do
  client.show_server_output
  client.provide_input_when_asked
end

# client = TestClient.new
# client.connect
# until client.socket.closed? do
#   client.show_server_output
#   client.provide_input_when_asked
# end
