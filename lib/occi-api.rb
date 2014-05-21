require 'rubygems'
require 'rubygems/package'

require 'ostruct'

require 'occi-core'

module Occi::Api; end
module Occi::Api::Client; end
module Occi::Api::Dsl; end
module Occi::Api::Client::Errors; end

require 'occi/api/version'
require 'occi/api/log'
require 'occi/api/client/authn_utils'
require 'occi/api/client/errors'
require 'occi/api/client/client_base'
require 'occi/api/client/client_http'
require 'occi/api/dsl'
