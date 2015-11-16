require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::EndGame < Spinach::FeatureSteps
  include Helpers
  include CommonSteps

  Spinach.hooks.before_scenario do |scenario|
    Match.reset
    User.reset_users
  end

  step 'a deck with one card left' do
    @match.game.deck.cards = [@card_nobody_has]
  end

  step 'the match tells me the game is over' do
    visit_player_page
    expect(page.has_content?(/game over/i)).to be true
  end
end
