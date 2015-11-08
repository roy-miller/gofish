require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require './lib/match_maker'
require './lib/match_perspective'
require 'pry'
also_reload("lib/**/*.rb")

# class Cache
#   @@match_maker = MatchMaker.new
#
#   def self.match_maker
#     @@match_maker
#   end
#
#   def self.match_maker=(value)
#     @@match_maker = value
#   end
# end

get('/') do
 slim :index
end

post '/start' do
  number_of_opponents = params['number_of_opponents']
  user_name = params['user_name']
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  match = Match.add_user(id: user_id, name: user_name, opponent_count: number_of_opponents)
  #match = Cache.match_maker.add_pending_user(id: user_id, name: user_name, opponents: number_of_opponents)
  redirect to("/matches/#{match.id}/users/#{match.user_with_name(user_name).id}")
end

post '/update' do
  @user_id = params['user_id'].to_i
  match = Match.find_for_user(@user_id)
  if match && match.started?
    redirect "/matches/#{match.id}/users/#{@user_id}"
  else
    redirect back
  end
end

# TODO this should be a post
get '/ask' do
  user_id_to_ask = params['id'].to_i
  card_rank_to_request = params['rank']

end

get '/matches/:match_id/users/:user_id.?:format?' do
  match = Match.find(params['match_id'].to_i) 
  match_user = match.match_user_for(params['user_id'].to_i)
  @perspective = MatchPerspective.new.for(match: match, with: match_user)
  slim :player
end
