require "curb"

module YandexFotki
  module HttpAdapter

    class Curb
      def get(url, headers = {})
        curl = Curl::Easy.new(url)
        curl.headers["Authorization"] = headers['Authorization'] if headers['Authorization']
        curl.http_get
        curl.body_str
      end

      def delete(url, headers)
        curl = Curl::Easy.new(url)
        curl.headers["Authorization"] = headers['Authorization']
        curl.http_delete
        curl.body_str
      end

      def post_form(url, form_data)
        curl = Curl::Easy.new(url)
        curl.http_post(
          Curl::PostField.content('request_id', form_data['request_id']),
          Curl::PostField.content('credentials', form_data['credentials'])
        )
        curl.body_str
      end

      def post_multipart(url, file, headers)
        curl = Curl::Easy.new(url)
        curl.headers["Authorization"] = headers['Authorization']
        curl.multipart_form_post = true
        curl.http_post(
          Curl::PostField.file('image', file.path, file.filename),
          Curl::PostField.content('yaru', '0')
        )
        curl.body_str
      end

      def put(url, data, headers)
        curl = Curl::Easy.new(url)
        curl.headers["Authorization"] = headers['Authorization']
        curl.headers["Content-Type"] = headers['Content-Type']
        curl.http_put(data)
        curl.body_str
      end
    end

  end
end