module Occi::Api::Client
  module Http

    module Helpers

      # @see Occi::Api::Client::ClientBase
      def get_logger(log_options)
        logger = super(log_options)
        self.class.debug_output $stderr if logger.level == Occi::Api::Log::DEBUG

        logger
      end

      # @see Occi::Api::Client::ClientBase
      def configure_connection(options)
        # timeout is the only global connection option at the moment
        self.class.default_timeout options[:timeout].to_i unless options[:timeout].blank?
      end

      # @see Occi::Api::Client::ClientBase
      def get_auth(auth_options, fallback = false)
        # select appropriate authN type
        @authn_plugin = case auth_options[:type]
                        when "basic", "digest", "x509", "token"
                          Http::AuthnPlugins.const_get(auth_options[:type].capitalize).new(
                            self,
                            auth_options
                          )
                        when "keystone"
                          raise ::Occi::Api::Client::Errors::AuthnError,
                                "This authN method is for fallback only!" unless fallback
                          Http::AuthnPlugins::Keystone.new self, auth_options
                        when "none", nil
                          Http::AuthnPlugins::Dummy.new self
                        else
                          raise ::Occi::Api::Client::Errors::AuthnError,
                                "Unknown authN method [#{@auth_options[:type]}]!"
                        end

        @authn_plugin.setup

        auth_options
      end

      # @see Occi::Api::Client::ClientBase
      def preauthenticate
        begin
          @authn_plugin.authenticate
        rescue ::Occi::Api::Client::Errors::AuthnError => e
          Occi::Api::Log.debug e.message

          if @authn_plugin.fallbacks.any?
            # TODO: multiple fallbacks
            @auth_options[:original_type] = @auth_options[:type]
            @auth_options[:type] = @authn_plugin.fallbacks.first

            @auth_options = get_auth(@auth_options, true)
            @authn_plugin.authenticate
          else
            raise e
          end
        end
      end

      # @see Occi::Api::Client::ClientBase
      def get_media_type(force_type = nil)
        # force media_type if provided
        unless force_type.blank?
          self.class.headers 'Accept' => force_type
          media_type = force_type
        else
          media_types = self.class.get(@endpoint.to_s).headers['accept']

          Occi::Api::Log.debug("Available media types: #{media_types.inspect}")
          media_type = case media_types
          when /application\/occi\+json/
            'application/occi+json'
          when /text\/occi/
            'text/occi'
          else
            'text/plain'
          end
        end

        media_type
      end

      # Generates a human-readable response message based on the HTTP response code.
      #
      # @example
      #    response_message self.class.delete(path)
      #     # =>  'HTTP Response status: [200] OK'
      #
      # @param response [HTTParty::Response] HTTParty response object
      # @return [String] message
      def response_message(response)
        @last_response = response
        "HTTP Response status: [#{response.code.to_s}] #{reason_phrase(response.code)}"
      end

    end

  end
end
