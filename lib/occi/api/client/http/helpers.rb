module Occi::Api::Client
  module Http

    module Helpers

      # @see Occi::Api::Client::ClientBase
      def get_logger(log_options)
        logger = super(log_options)
        self.class.debug_output $stderr if logger.level == Occi::Log::DEBUG

        logger
      end

      # @see Occi::Api::Client::ClientBase
      def get_auth(auth_options, fallback = false)
        # select appropriate authN type
        case auth_options[:type]
        when "basic"
          @authn_plugin = Http::AuthnPlugins::Basic.new self, auth_options
        when "digest"
          @authn_plugin = Http::AuthnPlugins::Digest.new self, auth_options
        when "x509"
          @authn_plugin = Http::AuthnPlugins::X509.new self, auth_options
        when "keystone"
          raise ::Occi::Api::Client::Errors::AuthnError, "This authN method is for fallback only!" unless fallback
          @authn_plugin = Http::AuthnPlugins::Keystone.new self, auth_options
        when "none", nil
          @authn_plugin = Http::AuthnPlugins::Dummy.new self
        else
          raise ::Occi::Api::Client::Errors::AuthnError, "Unknown authN method [#{@auth_options[:type]}]!"
        end

        @authn_plugin.setup

        auth_options
      end

      # @see Occi::Api::Client::ClientBase
      def preauthenticate
        begin
          @authn_plugin.authenticate
        rescue ::Occi::Api::Client::Errors::AuthnError => e
          Occi::Log.debug e.message

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
          media_types = self.class.head(@endpoint.to_s).headers['accept']

          Occi::Log.debug("Available media types: #{media_types.inspect}")
          media_type = case media_types
          when /application\/occi\+json/
            'application/occi+json'
          when /application\/occi\+xml/
            'application/occi+xml'
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
      #    response_message self.class.delete(@endpoint.to_s + path)
      #     # =>  'HTTP Response status: [200] OK'
      #
      # @param [HTTParty::Response] HTTParty response object
      # @return [String] message
      def response_message(response)
        @last_response = response
        "HTTP Response status: [#{response.code.to_s}] #{reason_phrase(response.code)}"
      end

    end

  end
end