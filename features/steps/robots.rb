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
    give_king(@me)
    set_my_hand_before_asking
    @expected_card = give_king(@first_opponent)
    visit_player_page
    click_to_ask_for_cards(@expected_card)
  end

  step 'my first opponent asks me for cards' do
    @first_opponent.match_changed
    visit_player_page
    expect(page.has_content?("#{@first_opponent.name} asked #{@me.name}")).to be true
  end
end
