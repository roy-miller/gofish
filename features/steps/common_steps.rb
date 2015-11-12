module CommonSteps
  module Parameterized
    def player_steps(player_count, *names)
      names.each do |name|
        step "#{name} plays a #{player_count} player game" do
          visit '/'
          fill_in 'user_name', with: name
          fill_in 'user_id', with: ''
          select player_count, from: 'number_of_opponents'
          click_button 'start_playing'
        end
      end
    end
  end
end
