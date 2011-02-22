module YandexFotki
  module ActiveRecord
    # Same as mount_uploader method but with before_save :store_image! callback
    def mount_before_save_uploader(*args)
      before_save "store_#{args.first.to_s}!"
      mount_uploader(*args)
    end
  end
end
