require 'capybara'
require 'capybara/rspec'
require './app'
require_relative '../../lib/match_maker.rb'
Capybara.app = Sinatra::Application

feature 'index page' do
  before do
    #Cache.match_maker = MatchMaker.new
    visit '/'
  end

  it 'shows player page when user asks to play' do
    #Match.add_user(id: 123, name: 'existing_oponent', opponent_count: 1)
    within 'form#game_options' do
      fill_in 'user_name', with: 'Player2'
      fill_in 'user_id', with: ''
      select '1', from: 'number_of_opponents'
      click_button 'start_playing'
    end
    expect(page).to have_content 'Welcome, Player2!'
    expect(page).to have_content 'Wait for another player to ask you for cards'
  end

end
