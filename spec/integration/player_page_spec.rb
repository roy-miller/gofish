require 'spec_helper'
require 'capybara'
require 'capybara/rspec'
require './app'
Capybara.app = Sinatra::Application

feature 'player display' do
  before do
    Match.matches = []
    @match = Match.find(0)
    @match.status = Status::STARTED
    visit "/matches/0/users/#{@match.match_users.first.id}"
  end

  it 'identifies player' do
    expect(page).to have_content 'Welcome, Player1!'
  end

  it 'shows the player hand' do
    player = @match.match_users.first.player
    expect(page).to have_css '#your_hand'
    expect(page).to have_css('.your-card', count: 5)
    player.hand.each do |card|
      expect(page).to have_css ".your-card.#{card.suit.downcase}#{card.rank.downcase}"
    end
  end

  it 'shows opponent hands' do
    opponent = @match.match_users.last.player
    expect(page).to have_css '#opponent_0_hand'
    expect(page).to have_css('.opponent-card', count: 5)
    opponent.hand.each do |card|
      expect(page).to have_css ".opponent-card.facedown"
    end
  end

  it 'shows the fish pond with count of cards left' do
    expect(page).to have_css '#fish_pond'
    expect(page).to have_content '42 cards left'
  end
end
