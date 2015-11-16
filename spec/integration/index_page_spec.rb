# require 'capybara'
# require 'capybara/rspec'
# require './app'
# Capybara.app = Sinatra::Application
#
# def ask_to_play_one_opponent(player_name:)
#   within 'form#game_options' do
#     fill_in 'user_name', with: player_name
#     fill_in 'user_id', with: ''
#     select '1', from: 'number_of_opponents'
#     click_button 'start_playing'
#   end
# end
#
# feature 'index page' do
#   before do
#     Match.matches  = []
#     visit '/'
#   end
#
#   it 'shows player page with initial when user asks to play and not enough players for a game' do
#     ask_to_play_one_opponent(player_name: 'Player2')
#     expect(page).to have_content 'Welcome, Player2!'
#     expect(page).to have_content 'Waiting for opponents for you'
#   end
#
#   it 'shows player page with hand when game started' do
#     Match.add_user(id: 123, name: 'existing_oponent', opponent_count: 1)
#     ask_to_play_one_opponent(player_name: 'Player2')
#     expect(page).to have_content 'Welcome, Player2!'
#     expect(page).to have_content 'Wait for another player to ask you for cards'
#   end
#
# end
