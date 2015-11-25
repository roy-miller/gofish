RSpec.configure do |config|
  puts "GOT TO factory_girl.rb"
  # config.include FactoryGirl::Syntax::Methods
  # # config.before(:suite) do
  # # begin
  # #   DatabaseCleaner.start
  # #   FactoryGirl.lint
  # # ensure
  # #   DatabaseCleaner.clean
  # # end
  # config.before(:suite) do
  #      DatabaseCleaner.clean_with(:truncation)
  # end
  # config.before(:each) do
  #      DatabaseCleaner.strategy = :transaction
  # end
  # config.before(:each, :js => true) do
  #      DatabaseCleaner.strategy = :truncation
  # end
  # config.before(:each) do
  #      DatabaseCleaner.start
  # end
  # config.after(:each) do
  #      DatabaseCleaner.clean
  # end
end
