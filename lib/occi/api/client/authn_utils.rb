module Occi::Api::Client

  class AuthnUtils

    CERT_REGEXP = /\n?(-----BEGIN CERTIFICATE-----\n.+?\n-----END CERTIFICATE-----)\n/m

    # Reads X.509 certificates from a file to an array.
    #
    # @example
    #    AuthnUtils.certs_to_file_ary "~/.globus/usercert.pem"
    #      # => [#<String>, #<String>, ...]
    #
    # @param ca_file [String] Path to a PEM file containing certificates
    # @return [Array<String>] An array of read certificates
    def self.certs_to_file_ary(ca_file)
      raise ArgumentError, "PKCS12 file #{ca_file.inspect} " \
                           "is not supported in VOMS mode!" if /\A(.)+\.p12\z/ =~ ca_file
      certs_str = File.open(ca_file).read

      certs_ary = certs_str.scan(CERT_REGEXP)
      certs_ary ? certs_ary.flatten : []
    end

  end

end
