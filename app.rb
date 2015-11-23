require 'json'
require 'pusher'
require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
also_reload("lib/**/*.rb")
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each {|file| require file } # glob better?

set :database, ENV['DATABASE_URL'] || 'postgres://localhost/gofish'
Pusher.url = "https://9d7c66d1199c3c0e7ca3:27c71591fef8b4fadd37@api.pusherapp.com/apps/153451"
@@match_maker = MatchMaker.new

get '/' do
 slim :index
end

post '/start' do
  @@match_maker = MatchMaker.new if (params['reset_match_maker'])
  @number_of_players = params['number_of_opponents'].to_i + 1
  user = User.find_or_create_by(name: params['user_name'])
  match = @@match_maker.match(user, @number_of_players)
  if match
    redirect "/matches/#{match.id}/users/#{user.id}"
  else
    @user_id = user.id
    @user_name = user.name
    slim :wait
  end
end

post '/request_card' do
  match = Match.find(params['match_id'].to_i)
  requestor = match.user_for_id(params['requestor_id'].to_i)
  recipient = match.user_for_id(params['requested_id'].to_i)
  match.ask_for_cards(requestor: requestor, recipient: recipient, card_rank: params['rank'].upcase)
  return
end

get '/matches/:match_id/users/:user_id.?:format?' do
  match = Match.find(params['match_id'].to_i)
  user = match.user_for_id(params['user_id'].to_i)
  state_for_user = match.state_for(user)
  if (params['format'] == 'json')
    state_for_user.to_json
  else
    @perspective = state_for_user
    slim :player
  end
end
