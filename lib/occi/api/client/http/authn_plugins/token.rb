module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Token < Base

        def setup(options = {})
          # set up token auth
          raise ArgumentError, "Missing required option 'token' for token auth!" if @options[:token].blank?
          raise ArgumentError, "Token cannot be a multi-line string!" if @options[:token].strip.lines.count > 1
          @env_ref.class.headers['X-Auth-Token'] = @options[:token].strip

          @env_ref.class.ssl_ca_path @options[:ca_path] if @options[:ca_path]
          @env_ref.class.ssl_ca_file @options[:ca_file] if @options[:ca_file]
        end

      end

    end
  end
end
