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

  gem.add_dependency 'occi-core', '>= 4.3.5', '< 5'
  gem.add_dependency 'httparty', '>= 0.13.1', '< 0.14'
  gem.add_dependency 'json', '>= 1.8.1', '< 3'

  gem.add_development_dependency 'vcr', '>= 3.0', '< 4'
  gem.add_development_dependency 'rubygems-tasks', '>= 0.2.4', '< 0.3'
  gem.add_development_dependency 'rspec', '>= 3.5.0', '< 4'
  gem.add_development_dependency 'rake', '>= 12', '< 13'
  gem.add_development_dependency 'builder', '>= 3.2.3', '< 4'
  gem.add_development_dependency 'simplecov', '>= 0.13', '< 1'
  gem.add_development_dependency 'yard', '>= 0.9.8', '< 1'
  gem.add_development_dependency 'yard-rspec', '>= 0.1', '< 1'
  gem.add_development_dependency 'rspec-http', '>= 0.11', '< 1'
  gem.add_development_dependency 'webmock', '>= 1.9.3', '< 2'
  gem.add_development_dependency 'pry', '>= 0.10.4', '< 1'

  gem.required_ruby_version = '>= 1.9.3'
end
