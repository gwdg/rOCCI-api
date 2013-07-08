module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Keystone < Base
        FALLBACKS = []

        def setup(options = {})
          response = @env_ref.class.head @env_ref.endpoint
          Occi::Log.debug response.inspect

          return if response.success?
          raise ::Occi::Api::Client::Errors::AuthnError, "Keystone AuthN failed with #{response.code.to_s}!" unless response.code == 401

          unless response.headers['www-authenticate'] && response.headers['www-authenticate'].start_with?('Keystone')
            raise ::Occi::Api::Client::Errors::AuthnError, "Target endpoint is probably not OpenStack!"
          end

          keystone_uri = /^Keystone uri='(.+)'$/.match(response.headers['www-authenticate'])[1]

          raise ::Occi::Api::Client::Errors::AuthnError, "Unable to get Keystone's URL from the response!" unless keystone_uri

          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = "application/json"
          headers['Accept'] = headers['Content-Type']

          response = @env_ref.class.post(keystone_uri + "/v2.0/tokens", :body => get_keystone_req, :headers => headers)
          Occi::Log.debug response.inspect

          if response.success?
            @env_ref.class.headers['X-Auth-Token'] = response['access']['token']['id']
          else
            raise ::Occi::Api::Client::Errors::AuthnError, "Unable to get a token from Keystone!"
          end
        end

        private

        def get_keystone_req(json = true)
          if @options[:type] == "x509"
            body = { "auth" => { "voms" => true } }
          elsif @options[:username] && @options[:password]
            body = {
              "auth" => {
                "passwordCredentials" => {
                  "username" => @options[:username],
                  "password" => @options[:password]
                }
              }
            }
          else
            raise ::Occi::Api::Client::Errors::AuthnError, "Unable to request a token from Keystone! Chosen AuthN not supported."
          end

          json ? body.to_json : body
        end

      end

    end
  end
end