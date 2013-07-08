module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Digest < Base
        FALLBACKS = %w(keystone)

        def setup(options = {})
          # set up digest auth
          raise ArgumentError, "Missing required options 'username' and 'password' for digest auth!" unless @options[:username] and @options[:password]
          @env_ref.class.digest_auth @options[:username], @options[:password]
        end

      end

    end
  end
end