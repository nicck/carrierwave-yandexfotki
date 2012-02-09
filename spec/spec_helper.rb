require 'rubygems'
require 'bundler/setup'

require 'active_record'

if ENV["COVERAGE"]
  require 'simplecov'

  SimpleCov.start {
    add_filter "/vendor/"
    add_filter "/spec/"
  }
end

require 'carrierwave'
require 'carrierwave-yandexfotki'

RSpec.configure do |config|
  config.mock_with :rspec
  config.fail_fast
end
