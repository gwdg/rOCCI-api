# load all plugins
Dir[File.join(File.dirname(__FILE__), 'authn_plugins', '*.rb')].each { |file| require file.gsub('.rb', '') }