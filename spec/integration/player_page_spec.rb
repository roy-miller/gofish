require 'capybara'
require 'capybara/rspec'
require './gofish_app'
require 'pry'
Capybara.app = Sinatra::Application

feature 'player display' do
  before do
    Match.matches = {}
    @match = Match.find(0)
    visit "/matches/0/users/#{@match.users.first.id}"
  end

  it 'identifies player' do
    expect(page).to have_content('Welcome, Player1!')
  end

  it 'shows the player hand' do
    player = @match.players.first
    expect(page).to have_css('#your_hand')
    expect(page).to have_css('.your-card', count: 5)
    player.cards.each do |card|
      expect(page).to have_css(".your-card.#{card.suit.downcase}#{card.rank.downcase}")
    end
  end

  it 'shows opponent hands' do
    opponent = @match.players.last
    expect(page).to have_css('#opponent_Player2_hand')
    expect(page).to have_css('.opponent-card', count: 5)
    opponent.cards.each do |card|
      expect(page).to have_css(".opponent-card.facedown")
    end
  end

  it 'shows the fish pond with count of cards left' do
    expect(page).to have_css('#fish_pond')
    expect(page).to have_content('42 cards left')
  end
end
