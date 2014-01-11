# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'occi/api/version'

Gem::Specification.new do |gem|
  gem.name          = "occi-api"
  gem.version       = Occi::Api::VERSION
  gem.authors       = ["Florian Feldhaus","Piotr Kasprzak", "Boris Parak"]
  gem.email         = ["florian.feldhaus@gwdg.de", "piotr.kasprzak@gwdg.de", "xparak@mail.muni.cz"]
  gem.description   = %q{This gem provides ready-to-use client classes to simplify the integration of OCCI into your application}
  gem.summary       = %q{OCCI development library providing a high-level API}
  gem.homepage      = 'https://github.com/gwdg/rOCCI-api'
  gem.license       = 'Apache License, Version 2.0'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency 'occi-core', '~> 4.2.5'
  gem.add_dependency 'httparty'
  gem.add_dependency 'json'

  gem.required_ruby_version     = ">= 1.9.3"
end
