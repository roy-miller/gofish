require './app'
require 'rspec'
require 'capybara'
require 'factory_girl'
require 'spinach/capybara'
require 'selenium-webdriver'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.app = Sinatra::Application
set(:show_exceptions, false) # what's this for?

Spinach::FeatureSteps.include Spinach::FeatureSteps::Capybara
Spinach.hooks.on_tag("javascript") { ::Capybara.current_driver = ::Capybara.javascript_driver }
Spinach.config[:failure_exceptions] << RSpec::Expectations::ExpectationNotMetError
Spinach::FeatureSteps.include RSpec::Matchers
Spinach::FeatureSteps.include FactoryGirl::Syntax::Methods
Spinach.hooks.before_run { FactoryGirl.reload }
