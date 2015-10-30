require 'sinatra'
require 'sinatra/reloader'
require './lib/game'
require './lib/player'
require 'pry'
also_reload("lib/**/*.rb")

# instantiate a gaem here
# what about when folks are waiting for somebody to play?

player1 = Player.new('Joe')
player2 = Player.new('Bob')
@@game = Game.new([player1, player2]).tap { |game| game.deal(cards_per_player: 5) }

get('/') do
 erb(:index)
end

get '/games/:game_id/player/:player_id.?:format?' do
  @player_number = params['player_id'].to_i
  @player = @@game.players[@player_number]
  #@player_name = @player.name
  erb :player
end
