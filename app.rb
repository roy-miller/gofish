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
  number_of_opponents = params['number_of_opponents'].to_i
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  match = Match.add_user(id: user_id, name: params['user_name'], opponent_count: number_of_opponents)
  if match.started?
    match.opponents_for(match.most_recent_user_added).each do |user|
      Pusher.trigger("player_channel_#{match.id}_#{user.id}", 'match_start_event', { message: 'match started' })
    end
  end
  redirect "/matches/#{match.id}/users/#{match.most_recent_user_added.id}"
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
