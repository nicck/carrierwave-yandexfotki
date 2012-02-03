require 'spec_helper'

require "yandexfotki/http_adapter/curb"
require "yandexfotki/http_adapter/net_http"
require "nokogiri"

describe YandexFotki::Connection do
  let(:file) { double "File" }
  let(:http_adapter) { double "HttpAdapter" }
  let(:connection) { YandexFotki::Connection.new(credentials) }
  let(:credentials) {
    { :login => 'ya_user', :password => 'ya_pass' }
  }
  let(:authorization_header) {
    { "Authorization"=>"FimpToken realm=\"fotki.yandex.ru\", token=\"tokenhash\"" }
  }
  let(:key_xml) {
    "<response>
       <key>keyhash</key>
       <request_id>requesthash</request_id>
    </response>"
  }
  let(:token_xml_str) {
    "<response>
      <token>tokenhash</token>
    </response>"
  }
  let(:image_info_xml) {
    '<entry xmlns="http://www.w3.org/2005/Atom" xmlns:app="http://www.w3.org/2007/app" xmlns:f="yandex:fotki">
      <foo>...skip...</foo>
      <content src="http://img-fotki.yandex.ru/get/5408/ya_user.1/0_6eacb_f7c350c7_orig" type="image/*" />
    </entry>'
  }

  before do
    YandexFotki::HttpAdapter::Curb.stub(:new).and_return(http_adapter)
  end

  describe 'initialization' do
    it 'should use YandexFotki::HttpAdapter::Curb http adapter' do
      YandexFotki::HttpAdapter::Curb.should_receive(:new)
      YandexFotki::Connection.new(credentials)
    end

    context 'credentials with net_http = true' do
      let(:nethttp_credentials) { credentials.merge(:net_http => true) }

      it 'should use YandexFotki::HttpAdapter::NetHttp http adapter' do
        YandexFotki::HttpAdapter::NetHttp.should_receive(:new)
        YandexFotki::Connection.new(nethttp_credentials)
      end
    end
  end

  describe '#post_foto' do
    # TODO: it shoud behave like authorized request

    it 'should return hash' do
      Rails = double "Rails"
      Rails.stub_chain(:cache, :fetch).and_yield

      YandexFotki::Encryptor.stub(:encrypt).and_return("credentials")

      stub_http_adapter

      connection.post_foto(file).should be_a(Hash)
    end

    it 'should post file to YF' do
      Rails.stub_chain(:cache, :fetch).and_yield

      YandexFotki::Encryptor.stub(:encrypt).and_return("credentials")

      stub_http_adapter

      http_adapter
        .should_receive(:post_multipart)
        .with("http://api-fotki.yandex.ru/post/", file, authorization_header )

      connection.post_foto(file)
    end
  end

  describe '#delete_foto' do
    # TODO: it shoud behave like authorized request

    it 'should send delete request to YF' do
      # TODO: remove duplication

      Rails.stub_chain(:cache, :fetch).and_yield

      YandexFotki::Encryptor.stub(:encrypt).and_return("credentials")

      stub_http_adapter

      http_adapter
        .should_receive(:delete)
        .with("http://api-fotki.yandex.ru/api/users/ya_user/photo/12345/", authorization_header)

      connection.delete_foto(12345)
    end
  end

  def stub_http_adapter
    http_adapter
      .stub(:get)
      .with("http://auth.mobile.yandex.ru/yamrsa/key/")
      .and_return(key_xml)

    http_adapter
      .stub(:post_form)
      .with(
        "http://auth.mobile.yandex.ru/yamrsa/token/",
        {"request_id"=>"requesthash", "credentials"=>"credentials"}
      ).and_return(token_xml_str)

    http_adapter
      .stub(:post_multipart)
      .with("http://api-fotki.yandex.ru/post/", file, authorization_header )
      .and_return("image_id=12345")

    http_adapter
      .stub(:get)
      .with("http://api-fotki.yandex.ru/api/users/ya_user/photo/12345/", authorization_header)
      .and_return(image_info_xml)
  end
end
