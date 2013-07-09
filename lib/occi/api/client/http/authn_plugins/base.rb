module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Base
        attr_reader :env_ref
        attr_reader :options

        def initialize(env_ref, options = {})
          @options = options
          @env_ref = env_ref
        end
        
        def setup(options = {}); end

        def authenticate(options = {})
          response = @env_ref.class.head @env_ref.endpoint
          raise ::Occi::Api::Client::Errors::AuthnError, "Authentication failed with code #{response.code.to_s}!" unless response.success?
        end

        def fallbacks
          FALLBACKS
        end

      end

    end
  end
end
