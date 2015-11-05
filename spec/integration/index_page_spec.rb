require 'capybara'
require 'capybara/rspec'
require './gofish_app'
require_relative '../../lib/match_maker.rb'
Capybara.app = Sinatra::Application

feature 'index page' do
  before do
    Cache.match_maker = MatchMaker.new
    visit '/'
  end

  it 'shows player page when user asks to play' do
    Cache.match_maker.add_pending_user(name: "existing_opponent")
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
