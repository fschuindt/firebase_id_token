require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start

require 'bundler/setup'
require 'redis'
require 'redis-namespace'
require 'httparty'
require 'jwt'
require 'firebase_id_token'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
