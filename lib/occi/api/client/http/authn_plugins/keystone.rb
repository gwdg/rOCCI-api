module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Keystone < Base

        def setup(options = {})
          # get Keystone URL if possible, get unscoped token
          set_keystone_base_url
          set_auth_token

          # use unscoped token for tenant discovery, get scoped token
          tenant = get_prefered_tenant
          set_auth_token(tenant)
        end

        def authenticate(options = {})
          # OCCI-OS doesn't support HEAD method!
          response = @env_ref.class.get "#{@env_ref.endpoint}-/"
          raise ::Occi::Api::Client::Errors::AuthnError, "Authentication failed with code #{response.code.to_s}!" unless response.success?
        end

        private

        def set_keystone_base_url
          response = @env_ref.class.head "#{@env_ref.endpoint}-/"
          Occi::Log.debug response.inspect

          return if response.success?
          raise ::Occi::Api::Client::Errors::AuthnError, "Keystone AuthN failed with #{response.code.to_s}!" unless response.code == 401

          unless response.headers['www-authenticate'] && response.headers['www-authenticate'].start_with?('Keystone')
            raise ::Occi::Api::Client::Errors::AuthnError, "Target endpoint is probably not OpenStack, fallback failed!"
          end

          @keystone_url = /^Keystone uri='(.+)'$/.match(response.headers['www-authenticate'])[1]
          raise ::Occi::Api::Client::Errors::AuthnError, "Unable to get Keystone's URL from the response!" unless @keystone_url

          @keystone_url = @keystone_url.chomp('/').chomp('/v2.0')
        end

        def set_auth_token(tenant = nil)
          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = "application/json"
          headers['Accept'] = headers['Content-Type']

          response = @env_ref.class.post(
            "#{@keystone_url}/v2.0/tokens",
            :body => get_keystone_req(tenant),
            :headers => headers
          )
          Occi::Log.debug response.inspect

          if response.success?
            @env_ref.class.headers['X-Auth-Token'] = response['access']['token']['id']
          else
            raise ::Occi::Api::Client::Errors::AuthnError, "Unable to get a token from Keystone!"
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
            raise ::Occi::Api::Client::Errors::AuthnError, "Unable to request a token from Keystone! Chosen AuthN not supported."
          end

          body['auth']['tenantName'] = tenant if tenant && !tenant.empty?
          body.to_json
        end

        def get_prefered_tenant(match = nil)
          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = "application/json"
          headers['Accept'] = headers['Content-Type']

          response = @env_ref.class.get(
            "#{@keystone_url}/v2.0/tenants",
            :headers => headers
          )
          Occi::Log.debug response.inspect

          # TODO: impl match with regexp in case of multiple tenants?
          raise ::Occi::Api::Client::Errors::AuthnError, "Keystone didn't return any tenants!" unless response['tenants'] && response['tenants'].first
          tenant = response['tenants'].first['name'] if response.success?
          raise ::Occi::Api::Client::Errors::AuthnError, "Unable to get a tenant from Keystone!" unless tenant

          tenant
        end

      end

    end
  end
end
