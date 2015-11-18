require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::Robots < Spinach::FeatureSteps
  include Helpers
  include CommonSteps

  Spinach.hooks.before_scenario do |scenario|
    Match.reset
    User.reset_users
  end

  step 'a game with one real player and one robot' do
    start_game_with_robots(real_player_count: 1, robot_count: 1)
  end

  step 'a game with one real player and two robots' do
    start_game_with_robots(real_player_count: 1, robot_count: 2)
  end

  step 'I ask my first opponent for cards he has' do
    visit_player_page
    @expected_card = @first_opponent.player.hand.first
    my_card_link = page.find(".your-card[data-rank='#{@expected_card.rank.downcase}'][data-suit='#{@expected_card.suit.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'my first opponent asks me for cards' do
    @first_opponent.match_changed
    visit_player_page
    expect(page.has_content?("#{@first_opponent.name} asked #{@me.name}")).to be true
  end
end
