require_relative 'common_steps'
require_relative 'helpers'

class Spinach::Features::Junk < Spinach::FeatureSteps
  Spinach.hooks.before_scenario do |scenario|
    Match.reset
  end

  step 'do junk' do
    puts "got here"
    visit '/'
  end

  step 'I see junk' do
    expect(page.has_content?("Welcome")).to be true
  end
end
