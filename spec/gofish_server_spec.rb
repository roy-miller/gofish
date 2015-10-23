require 'spec_helper'
require 'socket'

# see requests from other players
# make books
# see books
# make a request (ask player for cards)
# go fish
# see win/loss announcement
# get cards
# see cards
# click start for a 2-random-player game

describe Server do
  let(:server) { Server.new }
  let(:client) { MockClient.new }

  it 'does not listen when created' do
    begin
      client.connect
    rescue => e
      expect(e.message).to match /refused/
    end
  end

  context 'server running' do
    before do
      server.start
    end

    after do
      server.stop
    end

    it 'listens on default port when started' do
      expect { client.connect }.not_to raise_exception
    end

    it 'welcomes client when client connects' do
      client.connect
      server.accept_client
      expect(client.output).to match /welcome/i
      expect(server.clients.count).to eq 1
    end

    context 'one client' do
      let(:client) { MockClient.new }

      before do
        client.connect
        server.accept_client
      end

      it 'gets an id from the client' do
        id = 123
        client.provide_input(id)
        server.get_client_id(server.clients.first)
      end

      it 'asks new user for name' do
        client.provide_input('username')
        server.get_name(server.clients.first)
        expect(client.output).to match /.*type your name.*/i
      end

      it 'associates client with user' do
        client.provide_input('username')
        user = server.set_user_client(server.clients.first, nil)
        expect(user).not_to be_nil
        expect(user.client).to be server.clients.first
      end
    end

    context 'second client' do
      let(:client1) { MockClient.new }
      let(:client2) { MockClient.new }

      before do
        [client1, client2].each do
          client1.connect
          server.accept_client
        end
      end

      it 'starts a match when second client connects' do
        expect(client1.output).to match /.*you're now playing.*/mi
        expect(client2.output).to match /.*you're now playing.*/mi
        expect(server.games.count).to eq 1
      end
    end
  end

end
