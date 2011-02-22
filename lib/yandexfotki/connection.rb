require "yandexfotki/encryptor"

module YandexFotki

  class Connection
    API_HOSTNAME = 'api-fotki.yandex.ru'

    attr_reader :http

    def initialize(credentials)
      @login    = credentials[:login]
      @password = credentials[:password]

      if credentials[:net_http]
        require "yandexfotki/http_adapter/net_http"
        @http = YandexFotki::HttpAdapter::NetHttp.new
      else
        require "yandexfotki/http_adapter/curb"
        @http = YandexFotki::HttpAdapter::Curb.new
      end
    end

    def post_foto(file)
      image_id  = api_post_foto(file)
      image_url = api_get_foto_url(image_id)

      return {'image_url' => image_url, 'image_id' => image_id}
    end

    def delete_foto(image_id)
      resource_url = api_image_url(image_id)

      http.delete(resource_url, authorization_header)
    end

    private

    def authorization_header
      { "Authorization" => %(FimpToken realm="fotki.yandex.ru", token="#{get_token}") }
    end

    def api_post_foto(file)
      resource_url = "http://#{API_HOSTNAME}/post/"

      response = http.post_multipart(resource_url, file, authorization_header)
      image_id = response.split('=').last
    end

    def api_get_foto_info(image_id)
      resource_url = api_image_url(image_id)

      http.get(resource_url, authorization_header)
    end

    def api_set_foto_info(image_id, info_xml)
      resource_url = api_image_url(image_id)

      http.put(url, info_xml, authorization_header.merge("Content-Type" => 'application/atom+xml; type=entry'))
    end

    def get_token
      @token ||= Rails.cache.fetch "YandexFotki:token:#{@login}" do
        url = "http://auth.mobile.yandex.ru/yamrsa/key/"

        key_xml = http.get(url)

        xml = Nokogiri::XML(key_xml)

        key        = xml.xpath('/response/key').first.content
        request_id = xml.xpath('/response/request_id').first.content

        text = %(<credentials login="#{@login}" password="#{@password}"/>)
        credentials = Encryptor.encrypt(key, text)

        url = 'http://auth.mobile.yandex.ru/yamrsa/token/'
        form_data = {'request_id' => request_id, 'credentials' => credentials}
        token_xml_str = http.post_form(url, form_data)

        token_xml = Nokogiri::XML(token_xml_str)
        token_xml.xpath('/response/token').first.content
      end
    end

    def api_image_url(image_id)
      "http://#{API_HOSTNAME}/api/users/#{@login}/photo/#{image_id}/" if image_id.present?
    end

    def api_get_foto_url(image_id)
      img_url = nil

      attempts = 3
      while img_url.nil? && attempts > 0 do
        attempts -= 1

        info_xml    = api_get_foto_info(image_id)
        content_tag = Nokogiri::XML(info_xml).css('entry>content')

        img_url = content_tag.attribute('src').value rescue nil
      end

      raise "can't fetch src for foto ##{image_id}" if img_url.nil?

      img_url
    end
  end

end