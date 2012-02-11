require 'spec_helper'
require './spec/yandexfotki/http_adapter/shared_examples'

require "yandexfotki/http_adapter/net_http"

describe YandexFotki::HttpAdapter::NetHttp do
  before do
    ::File.stub(:open).and_return(double 'io')
    ::UploadIO.stub(:new).and_return('filepath')
  end

  it_should_behave_like "YandexFotki::HttpAdapter"
end
