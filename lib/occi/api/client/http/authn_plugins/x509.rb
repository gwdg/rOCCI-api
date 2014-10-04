module Occi::Api::Client
  module Http
    module AuthnPlugins

      class X509 < Base

        def initialize(env_ref, options = {})
          super env_ref, options
          @fallbacks = %w(keystone)
        end

        def setup(options = {})
          # set up pem and optionally pem_password and ssl_ca_path
          raise ArgumentError, "Missing required option 'user_cert' for x509 auth!" unless @options[:user_cert]
          raise ArgumentError, "The file specified in 'user_cert' does not exist!" unless File.exists? @options[:user_cert]

          # handle credentials, separate PKCS12 from PEM
          cert_content = File.open(@options[:user_cert], 'rb').read
          if /\A(.)+\.p12\z/ =~ @options[:user_cert]
            @env_ref.class.pkcs12 cert_content, @options[:user_cert_password]
          else
            @env_ref.class.pem cert_content, @options[:user_cert_password]
          end

          @env_ref.class.ssl_ca_path @options[:ca_path] if @options[:ca_path]
          @env_ref.class.ssl_ca_file @options[:ca_file] if @options[:ca_file]

          if @options[:voms]
            cert_ary = ::Occi::Api::Client::AuthnUtils.certs_to_file_ary @options[:user_cert]

            # remove the first cert since it was already used as pem_cert
            # use the rest to establish the chain of trust
            cert_ary.shift
            @env_ref.class.ssl_extra_chain_cert cert_ary unless cert_ary.empty?
          end
        end

      end

    end
  end
end
