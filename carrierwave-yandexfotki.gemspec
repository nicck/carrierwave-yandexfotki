# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yandexfotki/version"

Gem::Specification.new do |s|
  s.name        = "carrierwave-yandexfotki"
  s.version     = CarrierWave::YandexFotki::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nickolay Abdrafikov"]
  s.email       = ["nicck.olay@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{YandexFotki storage for CarrierWave gem}
  s.description = %q{This gem provides a simple way to upload files from Rails application to fotki.yandex.ru service.}

  s.rubyforge_project = "carrierwave-yandexfotki"

  s.add_dependency('carrierwave', '>= 0.5.2')
  s.add_dependency('nokogiri')
  s.add_dependency('curb')
  # s.add_dependency('multipart-post') # for net_http adapter

  s.add_development_dependency "rails", ">= 3.2.0"
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency('multipart-post') # for net_http adapter
  s.add_development_dependency('nokogiri')
  s.add_development_dependency('simplecov')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
