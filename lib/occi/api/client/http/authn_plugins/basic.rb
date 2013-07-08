module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Basic < Base
        FALLBACKS = %w(keystone)

        def setup(options = {})
          # set up basic auth
          raise ArgumentError, "Missing required options 'username' and 'password' for basic auth!" unless @options[:username] && @options[:password]
          @env_ref.class.basic_auth @options[:username], @options[:password]
        end

      end

    end
  end
end