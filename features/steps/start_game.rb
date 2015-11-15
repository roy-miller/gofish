require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::StartGame < Spinach::FeatureSteps
  #extend CommonSteps::Paramaterized
  #include Spinach::DSL
  include Helpers

  Spinach.hooks.before_scenario { |scenario| Match.reset }

  def ask_to_play(opponent_count: 1, player_name: 'player1' )
    in_browser(player_name) do
      visit '/'
      page.within("#game_options") do # page.* avoids rspec matcher clash
        fill_in 'user_name', with: player_name
        fill_in 'user_id', with: ''
        select opponent_count, from: 'number_of_opponents'
        click_button 'start_playing'
      end
    end
  end

  step 'I am on the welcome page' do
    visit '/'
  end

  step 'I choose my game options and play' do
    ask_to_play(opponent_count: 1, player_name: 'anyplayer')
  end

  step 'I play the game' do
    click_button 'start_playing'
  end

  step 'my player page tells me to wait for opponents' do
    in_browser('anyplayer') do
      expect(page.text).to match(/waiting for opponents/i)
    end
  end

  step 'I am waiting for a game with 2 players' do
    ask_to_play(opponent_count: 1, player_name: 'player1')
  end

  step 'another player joins the game' do
    ask_to_play(opponent_count: 1, player_name: 'player2')
  end

  step 'my player page shows the start of the game' do
    in_browser('player1') do
      expect(page.text).to match /ask another player/i
    end
  end
end
