require 'spec_helper'
require 'socket'

# MVP STORIES
# "click start" for a 2-random-player game
# get cards
# see cards
# go fish
# make books
# see books
# make a request (ask player for cards)
# see requests from other players
# see win/loss announcement

describe Server do
  let(:server) { Server.new }

  it 'does not listen when created' do
    begin
      MockClient.new.connect
    rescue => e
      expect(e.message).to match /refused/
    end
  end

  context 'started' do
    before do
      server.start
    end

    after do
      server.stop
    end

    it 'listens on default port when started' do
      expect { MockClient.new.connect }.not_to raise_exception
    end

    it 'accepts new client' do
      MockClient.new.connect
      server.accept_client
      expect(server.clients.count).to eq 1
    end

    context 'with one client' do
      let(:client) { MockClient.new }

      before do
        client.connect
        server.accept_client
      end

      it 'welcomes client' do
        server.welcome_client(server.clients.first)
        expect(client.output).to match /welcome/i
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
        user = server.find_user_for(server.clients.first, nil)
        expect(user).not_to be_nil
        expect(user.client).to be server.clients.first
      end

      context 'with second client' do
        let(:client2) { MockClient.new }
        let(:first_user) { User.new(name: 'first_user') }
        let(:second_user) { User.new(name: 'second_user') }

        before do
          client2.connect
          server.accept_client
        end

        it 'tells a client all player names for a match' do
          first_user.client = server.clients.first
          second_user.client = server.clients.last
          match = server.make_match(Game.new, [first_user, second_user])
          server.tell_player_names(match)
          [client, client2].each do |client|
            expect(client.output).to match(/.*first_user, second_user.*/i)
          end
        end

        it 'identifies when there are enough users for a match' do
          server.pending_users << first_user
          expect(server.enough_users_for_match?).to be false
          server.pending_users << second_user
          expect(server.enough_users_for_match?).to be true
        end

        it 'makes a game for users' do
          game = server.make_game_for([first_user, second_user])
          expect(game).not_to be_nil
          expect(game.players.count).to eq 2
          expect(game.players.first.name).to eq 'first_user'
          expect(game.players.last.name).to eq 'second_user'
        end

        it 'makes a match to associate users and a game' do
          game = Game.new([Player.new('first_user'), Player.new('second_user')])
          users = [first_user, second_user]
          match = server.make_match(game, users)
          expect(match).not_to be_nil
          expect(match.users).to match_array users
        end
      end
    end
  end
end
