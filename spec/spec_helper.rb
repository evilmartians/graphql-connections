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

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = true

  config.order = :random
  Kernel.srand config.seed
end
