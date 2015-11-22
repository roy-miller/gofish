Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each {|file| require file }
require 'sinatra'
require 'sinatra/reloader'
require 'pusher'
require 'pry'
require 'json'
also_reload("lib/**/*.rb")

Pusher.url = "https://9d7c66d1199c3c0e7ca3:27c71591fef8b4fadd37@api.pusherapp.com/apps/153451"
@@match_maker = MatchMaker.new

get '/' do
 slim :index
end

post '/start' do
  user_name = params['user_name']
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  number_of_players = params['number_of_opponents'].to_i + 1
  user = User.find(user_id) || User.new(name: user_name)
  match = @@match_maker.match(user, number_of_players)
  if match
    start_game(match)
    redirect "/matches/#{match.id}/users/#{user.id}"
  else
    ?
  end
end

post '/request_card' do
  match = Match.find(params['match_id'].to_i)
  requestor = match.match_user_for(params['requestor_id'].to_i)
  recipient = match.match_user_for(params['requested_id'].to_i)
  match.ask_for_cards(requestor: requestor, recipient: recipient, card_rank: params['rank'].upcase)
  return
end

get '/matches/:match_id/users/:user_id.?:format?' do
  match = Match.find(params['match_id'].to_i)
  match_user = match.match_user_for(params['user_id'].to_i)
  if (params['format'] == 'json')
    match.state_for(match_user).to_json
  else
    @perspective = match.state_for(match_user)
    slim :player
  end
end
