require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require './lib/match_maker'
require 'pry'
also_reload("lib/**/*.rb")

#   when you have a Match, start playing
#   that means ... messages go to players when they refresh the page? how without push?
# User can click card in his hand (to get value) and opponent name to ask him for cards
# User can click deck to go fish ... or that can happen automatically

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
  result = Cache.match_maker.add_pending_user(id: user_id, name: user_name)
  if result.is_a?(Match)
    match_id = Match.add_match(result) # match should have an id, not be in a hash
    user_just_added = result.user_with_name(user_name)
    redirect to("/matches/#{match_id}/users/#{user_just_added.id}") # this seems wrong
    return
  else
    @user_id = result.id
    @message = 'Waiting for opponents for you ...' # redirect ok if this in session
    slim :index
    #redirect to('/')
    #return
  end
end

post '/check' do
  @user_id = params['user_id'].to_i # hidden field isn't secure, what's a better way? devise auth?
  # binding.pry
  match = Match.find_for_user(@user_id)
  if match
    @message = "Ask another player for cards by clicking a card in your hand and then the opponent name"
    match_id = Match.matches.key(match) # should move match id to match, make matches an array
    redirect "/matches/#{match_id}/users/#{@user_id}?message=#{@message}"
  else
    @message = 'Still waiting for opponents ...'
    slim :index
  end
end

get '/matches/:match_id/users/:user_id.?:format?' do
  binding.pry
  match = Match.find(params['match_id'].to_i)
  user_id = params['user_id'].to_i
  @player = match.player_for(user_id) # match.players[player_number]
  @opponents = match.opponents_for(user_id) # players.reject { |player| player.name == @player.name  }
  @deck = match.game.deck # should I be reaching through like this?
  @message = params['message']
  slim :player
end

# likely kill this
get '/games/:game_id/player/:player_id.?:format?' do
  @game = Game.find(params['game_id'].to_i)
  @player_number = params['player_id'].to_i
  @player = @game.players[@player_number]
  @opponents = @game.players.reject { |player| player.name == @player.name  }
  slim :player
end
