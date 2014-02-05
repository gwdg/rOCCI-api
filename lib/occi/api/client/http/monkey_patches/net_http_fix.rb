##############################################################################
## Net::HTTP hack allowing the use of X.509 proxy certificates.
##############################################################################

module Net
  class HTTP

    old_verbose, $VERBOSE = $VERBOSE, nil

    if RUBY_VERSION =~ /^2\.\d/
      # For Rubies 2.0.x
      SSL_IVNAMES = SSL_IVNAMES.concat [:@extra_chain_cert]
      SSL_ATTRIBUTES = SSL_ATTRIBUTES.concat [:extra_chain_cert]

      attr_accessor :extra_chain_cert
    elsif RUBY_VERSION =~ /^1\.9/
      # For Rubies 1.9.x
      SSL_ATTRIBUTES = SSL_ATTRIBUTES.concat %w(extra_chain_cert)

      attr_accessor :extra_chain_cert
    elsif RUBY_VERSION =~ /^1\.8/
      # For legacy Rubies 1.8.x
      ssl_context_accessor :extra_chain_cert
    else
      # Nothing, not sure what to do!
    end

    $VERBOSE = old_verbose

  end
end
