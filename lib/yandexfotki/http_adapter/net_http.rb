require "net/http"
require "net/http/post/multipart" # multipart-post gem

module YandexFotki
  module HttpAdapter

    class NetHttp
      def get(url, headers = {})
        url = URI.parse(url)

        http = Net::HTTP.new(url.host)
        request = Net::HTTP::Get.new(url.path)
        request["Authorization"] = headers['Authorization'] if headers['Authorization']

        response = http.request(request)
        response.body
      end

      def delete(url, headers)
        url = URI.parse(url)

        http = Net::HTTP.new(url.host)
        request = Net::HTTP::Delete.new(url.path)
        request["Authorization"] = headers['Authorization']

        response = http.request(request)
        response.body
      end

      def post_form(url, form_data)
        url = URI.parse(url)

        response = Net::HTTP.post_form(url, form_data)
        response.body
      end

      def post_multipart(url, file, headers)
        url = URI.parse(url)

        file_io = ::File.open(file.path)
        form_data = {
          "image" => UploadIO.new(file_io, file.content_type, file.filename),
          "yaru"  => 0
        }

        http = Net::HTTP.new(url.host)
        request = Net::HTTP::Post::Multipart.new(url.path, form_data)
        request["Authorization"] = headers['Authorization']

        response = http.request(request, nil)
        response.body
      end

      def put(url, data, headers)
        url = URI.parse(url)

        http = Net::HTTP.new(url.host)
        request  = Net::HTTP::Put.new(url.path)
        request["Authorization"] = headers['Authorization']
        request['Content-Type'] = headers['Content-Type']

        response = http.request(request, data)
        response.body
      end
    end

  end
end
