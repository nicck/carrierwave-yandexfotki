require "yandexfotki/file_url"
require "yandexfotki/activerecord"
require "yandexfotki/connection"

require "carrierwave/storage/yandexfotki"

ActiveRecord::Base.extend YandexFotki::ActiveRecord

CarrierWave::Uploader::Base.send :include, YandexFotki::FileUrl

CarrierWave::Uploader::Base.add_config :yandex_login
CarrierWave::Uploader::Base.add_config :yandex_password
CarrierWave::Uploader::Base.add_config :yandex_net_http
