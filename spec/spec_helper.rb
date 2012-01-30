require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'carrierwave'
require 'carrierwave-yandexfotki'

RSpec.configure do |config|
  config.mock_with :rspec
  config.fail_fast
end
