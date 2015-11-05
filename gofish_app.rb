require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require './lib/match_maker'
require 'pry'
also_reload("lib/**/*.rb")

class Cache
  @@match_maker = MatchMaker.new

  def self.match_maker
    @@match_maker
  end

  def self.match_maker=(value)
    @@match_maker = value
  end
end

get('/') do
 slim :index
end

post '/start' do
  number_of_players = params['number_of_opponents']
  user_name = params['user_name']
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  match = Cache.match_maker.add_pending_user(id: user_id, name: user_name)
  if match.pending?
    @message = 'Waiting for opponents for you'
  else
    @message = 'Wait for another player to ask you for cards'
  end
  redirect to("/matches/#{match.id}/users/#{match.user_with_name(user_name).id}?message=#{@message}")
end

post '/update' do
  @user_id = params['user_id'].to_i
  match = Match.find_for_user(@user_id)
  if match && match.started?
    @message = "Ask another player for cards by clicking a card in your hand and then the opponent name"
    redirect "/matches/#{match.id}/users/#{@user_id}?message=#{@message}"
  else
    @message = 'Still waiting for opponents ...'
    redirect back
  end
end

get '/matches/:match_id/users/:user_id.?:format?' do
  @match = Match.find(params['match_id'].to_i)
  user_id = params['user_id'].to_i
  @user = User.find(user_id)
  @message = params['message']
  slim :player
end
