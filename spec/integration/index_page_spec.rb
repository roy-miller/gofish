require 'capybara'
require 'capybara/rspec'
require './gofish_app'
Capybara.app = Sinatra::Application

feature 'player page' do
  let(:player) { Player.new('Joe') }

  it 'identifies player' do
    visit '/games/0/player/0'
    expect(page).to have_content('Welcome, Joe!')
  end
end
