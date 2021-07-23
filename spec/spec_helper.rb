# frozen_string_literal: true

require "bundler/setup"
require "graphql/connections"
require "pry-byebug"

require "combustion"
Combustion.initialize! :active_record

require "rspec/rails"
require "test_prof/recipes/rspec/before_all"
require "test_prof/recipes/rspec/let_it_be"
require "test_prof/recipes/logging"
require "factory_bot_rails"
require "faker"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.filter_run_when_matching :focus

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = true

  # Add FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    Chewy.strategy(:bypass)
  end

  config.after(:suite) do
    Chewy.delete_all
  end

  config.order = :random
  Kernel.srand config.seed
end

TestProf::Rails::LoggingHelpers.all_loggables << Chewy
