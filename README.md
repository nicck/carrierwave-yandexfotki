YandexFotki storage for CarrierWave gem
=======================================

This gem provides a simple way to upload image files from Rails application to fotki.yandex.ru service.

Getting Started
---------------

In Rails, add it to your Gemfile:

    gem 'carrierwave-yandexfotki'

Quick Start
-----------

### Creating uploader

Start off by creating an uploader:

    app/uploaders/image_uploader.rb

It should look something like this:

    class ImageUploader < CarrierWave::Uploader::Base

      storage CarrierWave::Storage::YandexFotki

      yandex_login    'login'
      yandex_password 'password'

      ##
      #  Uncomment this if you want use 'net/http' library instead 'curb'.
      #  Also you need install 'multipart-post' gem for use this option.
      #
      #yandex_net_http true

      ##
      # This required for removing old image from fotki.yandex.ru
      # on updating image attached to model
      #
      before :cache, :remove_old_file_before_cache

      def remove_old_file_before_cache(new_file)
        remove! unless blank?
      end
    end

### Mount uploader

Add a string column to the model you want to mount the uploader on:

    add_column :products, :image, :string

Open your model file and mount the uploader:

    class Product
      mount_before_save_uploader :image, ImageUploader
    end

**NOTE!** You should use **`mount_before_save_uploader`** instead default `mount_uploader` method for YandexFotki storage.

### Usage

Now you can assign files to the attribute, they will automatically be uploaded when the record is saved.

    product = Product.new
    product.image = params[:file]
    product.save!
    product.image.url # => 'http://img-fotki.yandex.ru/get/path/to/file_orig'

You can get different versions (sizes) of the same image from fotki.yandex.ru (**without need to resize images on your server**):

    product.image.url       # original size image url
    product.image.url(:xl)  # image fitted to 800x800 px square
    product.image.url(100)  # image fitted to 100x100 px square

All available sizes:

     Size          |  Side of the bounding square, px
    ---------------+----------------------------------
     :orig or nil  |  Original size
     :xl   or 800  |  800
     :l    or 500  |  500
     :m    or 300  |  300
     :s    or 150  |  150
     :xs   or 100  |  100
     :xxs  or 75   |  75 
     :xxxs or 50   |  50 
    

You can find this info on this page: [http://api.yandex.ru/fotki/doc/appendices/photo-storage.xml][photo-storage]

[photo-storage]: http://api.yandex.ru/fotki/doc/appendices/photo-storage.xml

Limitations
-----------

- Only ActiveRecord ORM supported now.
- Only JPEG, GIF, PNG and BMP images available
- Limited set of image sizes available

Resources
---------

- [CarrierWave gem](https://github.com/jnicklas/carrierwave)
- [YandexFotki API documentation](http://api.yandex.ru/fotki/doc) on russian
