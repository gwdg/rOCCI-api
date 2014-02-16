module Occi::Api::Client
  module Base

    module ProtectedStubs

      # Sets global connection options before the first call
      # to a remote server is made. For example, this allows
      # the configuration of a global connection timeout, including
      # pre-authentication and authentication calls.
      #
      # @example
      #    configure_connection { :timeout => 180 }
      #
      # @param options [Hash] global options
      def configure_connection(options)
        raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
      end

      # Sets auth method and appropriate httparty attributes. Supported auth methods
      # are: ["basic", "digest", "x509", "none"]
      #
      # @example
      #    get_auth { :type => "none" }
      #    get_auth { :type => "basic", :username => "123", :password => "321" }
      #    get_auth { :type => "digest", :username => "123", :password => "321" }
      #    get_auth { :type => "x509", :user_cert => "~/cert.pem",
      #                  :user_cert_password => "321", :ca_path => nil }
      #
      # @param auth_options [Hash] authentication options
      # @param fallback [Boolean] allow fallback-only options
      # @return [Hash] transformed hash with authN information
      def get_auth(auth_options, fallback = false)
        raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
      end

      # Attempts to establish a preliminary connection with the server
      # to verify provided credentials and perform fallback authN
      # if necessary. Has to be invoked after @auth_options have been set.
      def preauthenticate
        raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
      end

      # Sets media type. Will choose either application/occi+json or text/plain
      # based on the formats supported by the server.
      #
      # @example
      #    get_media_type # => 'application/occi+json'
      #
      # @param force_type [String] type to be forcibly chosen
      # @return [String] chosen media type
      def get_media_type(force_type = nil)
        raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
      end

    end

  end
end