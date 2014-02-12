require 'rubygems'
require 'vcr'

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.add_filter "/spec/"
  SimpleCov.start
end

require 'occi-api'

# enable VCR for HTTP/HTTPS connections
# using RSPEC metadata integration;
# this will automatically generate a named
# cassette for each unit test
VCR.configure do |c|
  c.hook_into :webmock
 
  gem_root = File.expand_path '..', __FILE__
  c.cassette_library_dir = "#{gem_root}/cassettes"
  
  c.configure_rspec_metadata!
end

# simplify the usage of VCR; this will allow us to use
#
#   it "does something", :vcr do
#     ...
#   end
#
# instead of
#
#   it "does something else", :vcr => true do
#     ...
#   end
RSpec.configure do |c|
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.include(Occi::Helpers)
end
