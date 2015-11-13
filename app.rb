require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require './lib/match_perspective'
require './lib/request'
require 'pusher'
require 'pry'
require 'json'
also_reload("lib/**/*.rb")
Pusher.url = "https://9d7c66d1199c3c0e7ca3:27c71591fef8b4fadd37@api.pusherapp.com/apps/153451"

get('/') do
 slim :index
end

post '/start' do
  number_of_opponents = params['number_of_opponents'].to_i
  user_name = params['user_name']
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  match = Match.add_user(id: user_id, name: user_name, opponent_count: number_of_opponents)
  #refresh_player_pages(match, match.most_recent_user_added) if match.started?
  refresh_player_pages(match) if match.started?
  redirect to("/matches/#{match.id}/users/#{match.most_recent_user_added.id}")
end

post '/request_card' do
  match = Match.find(params['match_id'].to_i)
  requestor = match.match_user_for(params['requestor_id'].to_i)
  recipient = match.match_user_for(params['requested_id'].to_i)
  card_rank_to_request = params['rank']
  match.ask_for_cards(requestor: requestor, recipient: recipient, card_rank: card_rank_to_request)
  #refresh_player_pages(match, requestor)
  redirect to("/matches/#{match.id}/users/#{requestor.id}.json")
end

get '/matches/:match_id/users/:user_id.?:format?' do
  match = Match.find(params['match_id'].to_i)
  match_user = match.match_user_for(params['user_id'].to_i)
  if (params['format'] == 'json')
    inform_opponents(match, match_user)
    match.state_for(match_user).to_json
  else
    @perspective = match.state_for(match_user)
    slim :player
  end
end

def push(event:, to_channel:, with_data:)
  Pusher.trigger(to_channel, event, with_data)
end

def refresh_player_pages(match)
  Pusher.trigger("all_players_channel_#{match.id}", 'refresh_event', { message: "reload page" })
end

def inform_opponents(match, match_user)
  match.opponents_for(match_user).each do |opponent|
    match_state_for_opponent = match.state_for(opponent).to_json
    push(event: 'match_state_change_event',
         to_channel: "player_channel_#{match.id}_#{opponent.id}",
         with_data: match_state_for_opponent)
  end
end
