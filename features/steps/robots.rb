require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::Robots < Spinach::FeatureSteps
  include Helpers
  include CommonSteps

  step 'a game with one real player and one robot' do
    start_game_with_robots(humans: 1, robots: 1)
  end

  step 'a game with one real player and two robots' do
    start_game_with_robots(humans: 1, robots: 2)
  end

  step 'the robot thinks slowly' do
    @first_opponent.think_time = 10
    @match.save!
  end

  step 'the match tells the robot to play' do
    @first_opponent.think_time = 0
    set_current_player(@first_opponent)
    @match.reload
    @match.notify_observers
  end

  step 'I ask my first opponent for cards he has' do
    give_king(@me)
    set_my_hand_before_asking
    @expected_card = give_king(@first_opponent)
    @match.save!
    visit_player_page
    click_to_ask_for_cards(@expected_card)
  end

  step 'my first opponent asks me for cards' do
    sleep 3 # TODO how can I get rid of this?
    visit_player_page
    expect(page).to have_content("#{@first_opponent.name} asked #{@me.name}")
  end

  step 'the match tells me my first opponent asked second opponent for cards' do
    visit_player_page
    expect(page).to have_content("#{@first_opponent.name} asked #{@second_opponent.name}")
  end

  step 'play continues automatically back to me' do
    visit_player_page
    expect(page).to have_content("GAME OVER - #{@me.name} won")
  end
end
