module YandexFotki

  module FileUrl
    def url(*args)
      file.url(*args) || super
    end
  end

end
