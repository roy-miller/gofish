ENV['RACK_ENV'] = 'test'

require 'factory_girl'
require 'database_cleaner'
require 'pry'
require 'rspec'
#project_root = File.dirname(File.absolute_path(__FILE__))
#Dir.glob(project_root + '/helpers/*') {|file| require file}
#Dir.glob(project_root + '/helpers/*', &method(:require))
# def require_all(directory)
#   Dir[File.join(File.dirname(File.absolute_path(__FILE__)), directory, "**.rb")].each { |file| require file }
# end
# require_all 'lib'
# require_all 'spec/factories'
Dir[File.join(File.dirname(__FILE__), "..", "lib" , "**.rb")].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), "..", "spec/factories" , "**.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.clean_with(:truncation)
  #
  #   DatabaseCleaner.cleaning do
  #     FactoryGirl.lint
  #   end
  # end
end
