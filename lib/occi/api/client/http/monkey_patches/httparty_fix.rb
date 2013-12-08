##############################################################################
## HTTParty hack allowing the use of X.509 proxy certificates.
##############################################################################

module HTTParty
  class ConnectionAdapter

    private

    alias_method :old_attach_ssl_certificates, :attach_ssl_certificates

    def attach_ssl_certificates(http, options)
      old_attach_ssl_certificates(http, options)

      # Set chain of client certificates
      if options[:ssl_extra_chain_cert]
        http.extra_chain_cert = []

        options[:ssl_extra_chain_cert].each do |p_ca|
          http.extra_chain_cert << OpenSSL::X509::Certificate.new(p_ca)
        end
      end
    end
  end

  module ClassMethods

    def ssl_extra_chain_cert(ary_of_certs)
      default_options[:ssl_extra_chain_cert] = ary_of_certs
    end

  end
end
