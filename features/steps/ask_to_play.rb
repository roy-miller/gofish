require_relative './common_steps'

class Spinach::Features::AskToPlay < Spinach::FeatureSteps
  include CommonSteps::Parameterized

  def in_browser(name)
    old_session = Capybara.session_name
    Capybara.session_name = name
    yield
    Capybara.session_name = old_session
  end

  step 'I am on the welcome page' do
    visit '/'
  end

  step 'I choose my game options and play' do
    #print page.html
    #puts find("#game_options").native.inner_html
    #within("#game_options") do # why doesn't this work?
      fill_in 'user_name', with: 'Player1'
      fill_in 'user_id', with: ''
      select '1', from: 'number_of_opponents'
      click_button 'start_playing'
    #end
  end

  step 'I play the game' do
    click_button 'start_playing'
  end

  step 'my player page tells me to wait for opponents' do
    expect(page).to have_content "Waiting for opponents for you"
  end

  step 'I ask to play' do
    i_am_on_the_welcome_page
    i_choose_my_game_options_and_play
  end

  step 'there are enough players for a game' do
    in_browser(:player2) do
      player_steps 'Player2'
    end
  end

  step 'my player page shows the start of the game' do
    pending 'step not implemented'
  end
end
