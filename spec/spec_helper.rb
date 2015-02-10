ENV["RAILS_ENV"] ||= "test"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'factory_girl_rails'

unless FactoryGirl.factories.registered?(:document)
  # this is not needed when running `rspec spec` but
  # due to rake changing context of appliction when you
  # run `rake test` factories are not found corectly.
  # This ensures factories are registered
  ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
  Dir[File.join(ENGINE_RAILS_ROOT, "spec/factories/**/*.rb")].each {|f| require f }
end


Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include FactoryGirl::Syntax::Methods

  config.before :each do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
