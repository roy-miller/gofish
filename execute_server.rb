require_relative 'lib/server.rb'
require_relative 'test_server.rb'

Server.new(verbose: false).start.run

#TestServer.new.start.run
