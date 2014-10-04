require 'rspec'
require 'occi/api/client/authn_utils'

module Occi
  module Api
    module Client

      describe AuthnUtils do

        it "can read CA certificates from a file" do
          path = File.expand_path("..", __FILE__)

          ca_certs = AuthnUtils.certs_to_file_ary("#{path}/rocci-cred-cert.pem")
          ca_certs.should =~ [File.open("#{path}/rocci-cred-cert.pem", "rb").read.chomp("\n")]
        end

      end

    end
  end
end
