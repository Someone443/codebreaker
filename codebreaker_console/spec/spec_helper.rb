require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter 'main.rb'
end

Dir[Dir.pwd + '/helpers/*.rb'].each { |f| require f }
require_relative '../codebreaker_console.rb'
require_relative '../config/setup'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
