require_relative './common_steps'

class Spinach::Features::Crap < Spinach::FeatureSteps
  extend CommonSteps::Parameterized

  #play_game_steps(2, 'Player1')
  item_steps(1,2,3)
end
