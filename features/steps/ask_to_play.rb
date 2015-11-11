class Spinach::Features::AskToPlay < Spinach::FeatureSteps
  step 'I am on the welcome page' do
    visit '/'
  end

  step 'I choose my game options and play' do
    within 'form#game_options' do
      fill_in 'user_name', with: 'Player1'
      fill_in 'user_id', with: ''
      select '1', from: 'number_of_opponents'
      click_button 'start_playing'
    end
  end

  step 'I play the game' do
    within 'form#game_options' do
      click_button 'start_playing'
    end
  end

  step 'my player page tells me to wait for opponents' do
    expect(page).to have_content "Waiting for opponents for you"
    #page.has_content?('Waiting for opponents for you').must_equal true
  end

  step 'I asked to play' do
    pending 'step not implemented'
  end

  step 'there are enough players for a game' do
    pending 'step not implemented'
  end

  step 'my player page shows the start of the game' do
    pending 'step not implemented'
  end
end
