module CarrierWave
  module Storage

    class YandexFotki < Abstract
      class File
        def initialize(uploader, storage, identifier = nil)
          @uploader   = uploader
          @storage    = storage
          @identifier = identifier
        end

        ##
        # Remove the file from YandexFotki
        #
        def delete
          if @identifier && @identifier['image_id'].present?
            connection.delete_foto(@identifier['image_id'])
          end
        end

        ##
        # Returns the url on YandexFotki service
        #
        # === Returns
        #
        # [String] file's url
        #
        def url(style = nil)
          if style
            url_resized(style)
          else
            url_original
          end
        end

        def store(file)
          @identifier = connection.post_foto(file)
        end

        private

        def url_resized(size)
          if i = %w[800 500 300 150 100 75 50 ORIG ORIGINAL XL L M S XS XXS XXXS].index(size.to_s.upcase)
            suffix = %w[XL L M S XS XXS XXXS orig orig XL L M S XS XXS XXXS][i]
          else
            return nil
          end

          url_original.gsub(/_[^_]+$/, "_#{suffix}")
        end

        def url_original
          @identifier['image_url']
        end

        def connection
          @storage.connection
        end
      end

      ##
      # Store the file on YandexFotki
      #
      # === Parameters
      #
      # [file (CarrierWave::SanitizedFile)] the file to store
      #
      # === Returns
      #
      # [YandexFotki::File] the stored file
      #
      def store!(file)
        return if @image_identifier

        f = CarrierWave::Storage::YandexFotki::File.new(uploader, self, @identifier)
        @image_identifier = f.store(file)
        f
      end

      # YAML serialized hash with image info: image_url and image_id
      #
      # @return [String]
      #
      def identifier
        @image_identifier.to_yaml if @image_identifier.present?
      end

      # Do something to retrieve the file
      #
      # @param [String] identifier uniquely identifies the file
      #
      # [identifier (String)] uniquely identifies the file
      #
      # === Returns
      #
      # [YandexFotki::File] the stored file
      #
      def retrieve!(identifier)
        identifier = YAML.load(identifier)
        CarrierWave::Storage::YandexFotki::File.new(uploader, self, identifier)
      end

      def connection
        @connection ||= ::YandexFotki::Connection.new(
          :login    => uploader.yandex_login,
          :password => uploader.yandex_password,
          :net_http => uploader.yandex_net_http
        )
      end

    end # YandexFotki

  end
end
