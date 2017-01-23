# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'occi/api/version'

Gem::Specification.new do |gem|
  gem.name          = 'occi-api'
  gem.version       = Occi::Api::VERSION
  gem.authors       = ['Florian Feldhaus','Piotr Kasprzak', 'Boris Parak']
  gem.email         = ['florian.feldhaus@gmail.com', 'piotr.kasprzak@gwdg.de', 'parak@cesnet.cz']
  gem.description   = %q{This gem provides ready-to-use client classes to simplify the integration of OCCI into your application}
  gem.summary       = %q{OCCI development library providing a high-level client API}
  gem.homepage      = 'https://github.com/EGI-FCTF/rOCCI-api'
  gem.license       = 'Apache License, Version 2.0'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ['lib']

  gem.add_dependency 'occi-core', '~> 4.3', '>= 4.3.2'
  gem.add_dependency 'httparty', '~> 0.13', '>= 0.13.1'
  gem.add_dependency 'json', '~> 1.8', '>= 1.8.1'

  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'rubygems-tasks'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'builder'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'yard-rspec'
  gem.add_development_dependency 'rspec-http'
  gem.add_development_dependency 'webmock', '~> 1.9.3'

  gem.required_ruby_version = '>= 1.9.3'
end
