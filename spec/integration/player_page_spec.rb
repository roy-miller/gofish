require 'capybara'
require 'capybara/rspec'
require './gofish_app'
Capybara.app = Sinatra::Application

feature 'player display' do
  let(:player) { Player.new('Joe') }
  let(:opponent) { Player.new('Opponent1') }

  before do
    cards = []
    cards << Card.new(rank: '2', suit: 'S')
    cards << Card.new(rank: 'K', suit: 'H')
    cards << Card.new(rank: '6', suit: 'C')
    cards << Card.new(rank: '4', suit: 'S')
    cards << Card.new(rank: 'A', suit: 'D')
    player.add_cards_to_hand(cards)
  end

  it 'identifies player' do
    visit '/games/0/player/0'
    expect(page).to have_content('Welcome, Joe!')
  end

  it 'shows the player hand' do
    visit '/games/0/player/0'
    expect(page).to have_css('#your_hand')
    expect(page).to have_css('.your-card', count: 5)
  end
end
