require_relative 'lib/client.rb'

client = Client.new
#client = Client.new(verbose: true)
client.connect
client.run
