require_relative './common_steps'

class Spinach::Features::AskToPlay < Spinach::FeatureSteps
  #extend CommonSteps::Parameterized

  def in_browser(name)
    old_session = ::Capybara.session_name
    ::Capybara.session_name = name
    yield
    ::Capybara.session_name = old_session
  end

  step 'I am on the welcome page' do
    visit '/'
  end

  step 'I choose my game options and play' do
    page.within("#game_options") do # must have page.* to avoid rspec matcher clash
      fill_in 'user_name', with: 'Player1'
      fill_in 'user_id', with: ''
      select '1', from: 'number_of_opponents'
      click_button 'start_playing'
    end
  end

  step 'I play the game' do
    click_button 'start_playing'
  end

  step 'my player page tells me to wait for opponents' do
    expect(page.text).to match(/waiting for opponents/i)
  end

  step 'I ask to play' do
    in_browser(:player1) do
      play_game_steps(2, 'Player1')
    end
  end

  step 'there are enough players for a game' do
    in_browser(:player2) do
      play_game_steps(2, 'Player2')
    end
  end

  step 'my player page shows the start of the game' do
    in_browser(:player1) do
      expect(page.text).to match /ask another player/i
    end
  end

  step 'check this' do
    in_browser(:player1) do
      i_am_on_the_welcome_page
      i_choose_my_game_options_and_play
      expect(page.text).to match(/waiting for opponents/i)
    end
    in_browser(:player2) do
      i_am_on_the_welcome_page
      i_choose_my_game_options_and_play
      expect(page.text).to match(/wait for another player/i)
    end
    in_browser(:player1) do
      visit current_path
      expect(page.text).to match(/ask another player/i)
    end
  end
end
