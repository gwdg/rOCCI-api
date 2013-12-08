# load all plugins
require File.join(File.dirname(__FILE__), 'authn_plugins', 'base')
Dir[File.join(File.dirname(__FILE__), 'authn_plugins', '*.rb')].each { |file| require file.gsub('.rb', '') }