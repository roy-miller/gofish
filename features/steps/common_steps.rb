# module CommonSteps
#   module Parameterized
#     include Spinach::DSL
#
#     def play_game_steps(player_count, *player_names)
#       player_names.each do |player_name|
#         step "#{player_name} plays a #{player_count} player game" do
#           # visit '/'
#           # page.within("#game_options") do # page.* avoids rspec matcher clash
#           #   fill_in 'user_name', with: player_names
#           #   fill_in 'user_id', with: ''
#           #   select player_count, from: 'number_of_opponents'
#           #   click_button 'start_playing'
#           # end
#         end
#       end
#     end
#
#   end
# end

module CommonSteps
  module Paramaterized
    def play_game(player_count, *player_names)
      player_names.each do |name|
        step "#{name} plays a #{player_count} player game" do
          puts "saw #{name} of #{player_count}"
          visit '/'
          page.within("#game_options") do # page.* avoids rspec matcher clash
            fill_in 'user_name', with: name
            fill_in 'user_id', with: ''
            select player_count, from: 'number_of_opponents'
            click_button 'start_playing'
          end
        end
      end
    end
  end
end
