module Occi::Api::Client
  module Http
    module AuthnPlugins

      class X509 < Base
        FALLBACKS = %w(keystone)

        def setup(options = {})
          # set up pem and optionally pem_password and ssl_ca_path
          raise ArgumentError, "Missing required option 'user_cert' for x509 auth!" unless @options[:user_cert]
          raise ArgumentError, "The file specified in 'user_cert' does not exist!" unless File.exists? @options[:user_cert]

          # handle PKCS#12 credentials before passing them
          # to httparty
          if /\A(.)+\.p12\z/ =~ @options[:user_cert]
            pem_cert = ::Occi::Api::Client::AuthnUtils.extract_pem_from_pkcs12(@options[:user_cert], @options[:user_cert_password])
            @env_ref.class.pem pem_cert, ''
          else
            # httparty will handle ordinary PEM formatted credentials
            # TODO: Issue #49, check PEM credentials in jRuby
            pem_cert = File.open(@options[:user_cert], 'rb').read
            @env_ref.class.pem pem_cert, @options[:user_cert_password]
          end

          @env_ref.class.ssl_ca_path @options[:ca_path] if @options[:ca_path]
          @env_ref.class.ssl_ca_file @options[:ca_file] if @options[:ca_file]

          if @options[:proxy_ca]
            cert_ary = ::Occi::Api::Client::AuthnUtils.certs_to_file_ary @options[:proxy_ca]
            @env_ref.class.ssl_extra_chain_cert cert_ary
          end
        end

      end

    end
  end
end