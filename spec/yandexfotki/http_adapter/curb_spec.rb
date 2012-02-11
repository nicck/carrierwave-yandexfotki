require 'spec_helper'
require './spec/yandexfotki/http_adapter/shared_examples'

require "yandexfotki/http_adapter/curb"

describe YandexFotki::HttpAdapter::Curb do
  it_should_behave_like "YandexFotki::HttpAdapter"
end
