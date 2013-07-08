module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Dummy < Base
        FALLBACKS = []

        def authenticate(options = {}); end

      end

    end
  end
end