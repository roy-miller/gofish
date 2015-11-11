require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require './lib/match_perspective'
require './lib/request'
require 'pusher'
require 'pry'
also_reload("lib/**/*.rb")
Pusher.url = "https://9d7c66d1199c3c0e7ca3:27c71591fef8b4fadd37@api.pusherapp.com/apps/153451"

def refresh_opponent_pages(match, user)
  match.opponents_for(user).each do |user|
    Pusher.trigger("player_channel_#{match.id}", 'refresh_event', { message: "reload page" })
  end
end

get('/') do
 slim :index
end

post '/start' do
  number_of_opponents = params['number_of_opponents'].to_i
  user_name = params['user_name']
  user_id = params['user_id'].empty? ? nil : params['user_id'].to_i
  match = Match.add_user(id: user_id, name: user_name, opponent_count: number_of_opponents)
  refresh_opponent_pages(match, match.most_recent_user_added) if match.started?
  redirect to("/matches/#{match.id}/users/#{match.most_recent_user_added.id}")
end

post '/request_card' do
  match = Match.find(params['match_id'].to_i)
  requestor = match.match_user_for(params['requestor_id'].to_i)
  recipient = match.match_user_for(params['requested_id'].to_i)
  card_rank_to_request = params['rank']
  match.ask_for_cards(requestor: requestor, recipient: recipient, card_rank: card_rank_to_request)
  refresh_opponent_pages(match, requestor)
  redirect "/matches/#{match.id}/users/#{requestor.id}"
end

get '/matches/:match_id/users/:user_id.?:format?' do
  match = Match.find(params['match_id'].to_i)
  match_user = match.match_user_for(params['user_id'].to_i)
  @perspective = match.state_for(match_user)
  # if @perspective.messages.empty?
  #   puts "\n\n**********"
  #   puts "missing messages for user #{match_user.name} ->"
  #   puts "  messages for user: #{match.messages[match_user]}"
  #   puts "**********\n\n"
  # end
  slim :player
end

# TODO this goes away with pusher
# post '/update' do
#   @user_id = params['user_id'].to_i
#   match = Match.find_for_user_id(@user_id)
#   if (match && match.started?)
#     redirect "/matches/#{match.id}/users/#{@user_id}"
#   else
#     redirect back
#   end
# end
