# load all fixes
Dir[File.join(File.dirname(__FILE__), 'monkey_patches', '*.rb')].each { |file| require file.gsub('.rb', '') }