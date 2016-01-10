module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Keystone < Base

        KEYSTONE_URI_REGEXP = /^(Keystone|snf-auth) uri='(.+)'$/

        def setup(options = {})
          # get Keystone URL if possible
          set_keystone_base_url

          if !ENV['ROCCI_CLIENT_KEYSTONE_TENANT'].blank?
            # get a scoped token for the specified tenant directly
            set_auth_token ENV['ROCCI_CLIENT_KEYSTONE_TENANT']
          else
            # get an unscoped token, use the unscoped token
            # for tenant discovery and get a scoped token
            set_auth_token
            get_first_working_tenant
          end

          raise ::Occi::Api::Client::Errors::AuthnError,
                "Unable to get a tenant from Keystone, fallback failed!" if @env_ref.class.headers['X-Auth-Token'].blank?
        end

        def authenticate(options = {})
          # OCCI-OS doesn't support HEAD method!
          response = @env_ref.class.get "#{@env_ref.endpoint.to_s}/-/"
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Authentication failed with code #{response.code.to_s}!" unless response.success?
        end

        private

        def set_keystone_base_url
          response = @env_ref.class.get "#{@env_ref.endpoint.to_s}/-/"
          Occi::Api::Log.debug response.inspect

          return if response.success?
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Keystone AuthN failed with #{response.code.to_s}!" unless response.code == 401

          process_headers(response)
        end

        def process_headers(response)
          authN_header = response.headers['www-authenticate']

          if authN_header.blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Response does not contain the www-authenticate header, fallback failed!"
          end

          match = KEYSTONE_URI_REGEXP.match(authN_header)
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Unable to get Keystone's URL from the response, fallback failed!" unless match && match[2]

          @keystone_url = match[2].chomp('/').chomp('/v2.0')
        end

        def set_auth_token(tenant = nil)
          response = @env_ref.class.post(
            "#{@keystone_url}/v2.0/tokens",
            :body => get_keystone_req(tenant),
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          if response.success?
            @env_ref.class.headers['X-Auth-Token'] = response['access']['token']['id']
          else
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
          end
        end

        def get_keystone_req(tenant = nil)
          if @options[:original_type] == "x509"
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
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to request a token from Keystone! Chosen " \
                  "AuthN is not supported, fallback failed!"
          end

          body['auth']['tenantName'] = tenant unless tenant.blank?
          body.to_json
        end

        def get_first_working_tenant
          response = @env_ref.class.get(
            "#{@keystone_url}/v2.0/tenants",
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          raise ::Occi::Api::Client::Errors::AuthnError,
                "Keystone didn't return any tenants, fallback failed!" if response['tenants'].blank?

          response['tenants'].each do |tenant|
            begin
              Occi::Api::Log.debug "Authenticating for tenant #{tenant['name'].inspect}"
              set_auth_token(tenant['name'])

              # found a working tenant, stop looking
              break
            rescue ::Occi::Api::Client::Errors::AuthnError
              # ignoring and trying the next tenant
            end
          end
        end

        def get_req_headers
          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = "application/json"
          headers['Accept'] = headers['Content-Type']

          headers
        end

      end

    end
  end
end
