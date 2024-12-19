# frozen_string_literal: true

# spec/spec_helper.rb
RSpec.configure do |config|
  Dir[File.expand_path('spec/shared_examples/**/*.rb')].each { |file| require file }
  Dir[File.expand_path('spec/shared_context/**/*.rb')].each { |file| require file }

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
