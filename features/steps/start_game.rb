require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::StartGame < Spinach::FeatureSteps
  include Helpers

  Spinach.hooks.before_scenario do |scenario|
    Match.reset
    User.reset_users
  end

  step 'I choose my game options and play' do
    ask_to_play
  end

  step 'the match tells me to wait for opponents' do
    expect(page.text).to match(/waiting for players/i)
  end

  step 'I am waiting for a game with 2 players' do
    wait_for_game_with_two_players(desired_player_count: 2)
    @match.start_timeout_seconds = 0
  end

  step 'another player joins the game' do
    ask_to_play(opponent_count: 1, player_name: 'user2', user_id: 2)
  end

  step 'a player joins with the wrong number of opponents' do
    ask_to_play(opponent_count: 2, player_name: 'user2', user_id: 2)
  end

  step 'no other player joins in time' do
    @match.trigger_start_timer(0.25)
    sleep 0.5
  end

  step 'I see the start of the game' do
    visit "/matches/0/users/#{Match.matches.first.match_users.first.id}"
    expect(page.text).to have_text /welcome.*user1/i
    expect(page.text).to have_text /click a card/i
  end

  step 'I am playing one opponent' do
    expect(find_all('.opponent').length).to eq 1
    expect(find('.opponent').text).to match /user2/i
  end

  step 'I am playing one robot' do
    expect(find_all('.opponent').length).to eq 1
    expect(find('.opponent').text).to match /robot1/i
  end
end
