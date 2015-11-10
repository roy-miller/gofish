require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require './lib/match_perspective'
require './lib/request'
require 'pry'
also_reload("lib/**/*.rb")

get('/') do
 slim :index
end

post '/start' do
  number_of_opponents = params['number_of_opponents'].to_i
  user_name = params['user_name']
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  match = Match.add_user(id: user_id, name: user_name, opponent_count: number_of_opponents)
  redirect to("/matches/#{match.id}/users/#{match.user_with_name(user_name).id}")
end

# TODO this goes away with pusher
post '/update' do
  @user_id = params['user_id'].to_i
  match = Match.find_for_user_id(@user_id)
  if match && match.started?
    redirect "/matches/#{match.id}/users/#{@user_id}"
  else
    redirect back
  end
end

# TODO this should be a post
get '/ask' do
  match = Match.find(params['match_id'].to_i)
  requestor = match.match_user_for(params['requestor_id'].to_i)
  #redirect back if requestor != match.current_user
  recipient = match.match_user_for(params['requested_id'].to_i)
  card_rank_to_request = params['rank']
  match.ask_for_cards(requestor: requestor, recipient: recipient, card_rank: card_rank_to_request)
  redirect "/matches/#{match.id}/users/#{requestor.id}"
end

get '/matches/:match_id/users/:user_id.?:format?' do
  match = Match.find(params['match_id'].to_i)
  match_user = match.match_user_for(params['user_id'].to_i)
  # @perspective = match.state
  @perspective = MatchPerspective.new.for(match: match, user: match_user)
  slim :player
end
