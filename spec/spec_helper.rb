#project_root = File.dirname(File.absolute_path(__FILE__))
#Dir.glob(project_root + '/helpers/*') {|file| require file}
#Dir.glob(project_root + '/helpers/*', &method(:require))

require 'factory_girl'
require 'pry'
require 'rspec'
# def require_all(directory)
#   Dir[File.join(File.dirname(File.absolute_path(__FILE__)), directory, "**.rb")].each { |file| require file }
# end
# require_all 'lib'
# require_all 'spec/factories'
Dir[File.join(File.dirname(__FILE__), "..", "lib" , "**.rb")].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), "..", "spec/factories" , "**.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
