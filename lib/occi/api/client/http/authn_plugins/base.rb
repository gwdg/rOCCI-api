module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Base
        attr_reader :env_ref
        attr_reader :options
        attr_reader :fallbacks

        def initialize(env_ref, options = {})
          @options = options
          @env_ref = env_ref
          @fallbacks = []
        end

        def setup(options = {}); end

        def authenticate(options = {})
          response = @env_ref.class.get("#{@env_ref.endpoint.to_s}/-/")
          raise ::Occi::Api::Client::Errors::AuthnError, "Authentication failed with code #{response.code.to_s}!" unless response.success?
        end

      end

    end
  end
end
