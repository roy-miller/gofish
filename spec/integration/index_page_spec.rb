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

  it 'welcomes visitor' do
    expect(page).to have_content('Welcome')
  end

  it 'asks for user name' do
    expect(page).to have_css('#user_name')
  end

  it 'asks for user id' do
    expect(page).to have_css('#user_id')
  end

  it 'asks for number of players' do
    expect(page).to have_css('#number_of_opponents')
  end

  context 'with player asking to play' do
    before do
      within 'form#game_options' do
        fill_in 'user_name', with: 'Player1'
        fill_in 'user_id', with: ''
        select '1', from: 'number_of_opponents'
        click_button 'start_playing'
      end
    end

    it 'says to wait when user asks to play but no opponent exists yet' do
      expect(page).to have_content 'Waiting for opponents for you ...'
    end

    it 'shows index page when user checks for opponents when none exist' do
      click_button 'check_opponents'
      expect(page).to have_content 'Still waiting for opponents'
    end
  end

  it 'shows player page when user asks to play and opponent exists' do
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
