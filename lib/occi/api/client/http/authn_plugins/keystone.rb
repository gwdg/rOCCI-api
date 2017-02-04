module Occi::Api::Client
  module Http
    module AuthnPlugins

      class Keystone < Base

        KEYSTONE_URI_REGEXP = /^(Keystone|snf-auth) uri=("|')(.+)("|')$/
        KEYSTONE_VERSION_REGEXP = /^v([0-9]).*$/

        def setup(options = {})
          # get Keystone URL if possible
          set_keystone_base_url

          # discover Keystone API version
          @env_ref.class.headers.delete 'X-Auth-Token'
          set_auth_token ENV['ROCCI_CLIENT_KEYSTONE_TENANT']

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
                "Unable to get Keystone's URL from the response, fallback failed!" unless match && match[3]

          @keystone_url = match[3]
        end

        def set_auth_token(tenant = nil)
          response = @env_ref.class.get @keystone_url
          Occi::Api::Log.debug response.inspect

          raise ::Occi::Api::Client::Errors::AuthnError,
                "Unable to get Keystone API version from the response, fallback failed!" if (400..599).include?(response.code)

          # multiple choices, sort them by version id
          if response.code == 300
            versions = response['versions']['values'].sort_by { |v| v['id']}
          else
            # assume a single version
            versions = [response['version']]
          end

          versions.each do |v|
            match = KEYSTONE_VERSION_REGEXP.match(v['id'])
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get Keystone API version from the response, fallback failed!" unless match && match[1]
            if match[1] == '2'
              handler_class = KeystoneV2
            elsif match[1] == '3'
              handler_class = KeystoneV3
            end
            v['links'].each do |link|
              begin
                if link['rel'] == 'self'
                 keystone_url = link['href'].chomp('/')
                 keystone_handler = handler_class.new(keystone_url, @env_ref, @options)
                 token = keystone_handler.set_auth_token(tenant)
                 # found a working keystone, stop looking
                 return
                end
              rescue ::Occi::Api::Client::Errors::AuthnError
                # ignore and try with next link
              end
            end
          end
        end

      end

      class KeystoneV2
        def initialize(base_url, env_ref, options = {})
          @base_url = base_url
          @env_ref = env_ref
          @options = options
        end

        def set_auth_token(tenant = nil)
          if !tenant.blank?
            # get a scoped token for the specified tenant directly
            authenticate ENV['ROCCI_CLIENT_KEYSTONE_TENANT']
          else
            # get an unscoped token, use the unscoped token
            # for tenant discovery and get a scoped token
            authenticate
            get_first_working_tenant
          end
        end

        def authenticate(tenant = nil)
          response = @env_ref.class.post(
            "#{@base_url}/tokens",
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
            "#{@base_url}/tenants",
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          raise ::Occi::Api::Client::Errors::AuthnError,
                "Keystone didn't return any tenants, fallback failed!" if response['tenants'].blank?

          response['tenants'].each do |tenant|
            begin
              Occi::Api::Log.debug "Authenticating for tenant #{tenant['name'].inspect}"
              authenticate(tenant['name'])

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

      class KeystoneV3
        def initialize(base_url, env_ref, options = {})
          @base_url = base_url
          @env_ref = env_ref
          @options = options
        end

        def set_auth_token(tenant = nil)
          if @options[:original_type] == "x509"
            voms_authenticate(tenant)
          elsif @options[:username] && @options[:password]
            passwd_authenticate(tenant)
          else
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to request a token from Keystone! Chosen " \
                  "AuthN is not supported, fallback failed!"
          end
        end

        def passwd_authenticate(tenant = nil)
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Needs to be implemented, check http://developer.openstack.org/api-ref-identity-v3.html#authenticatePasswordUnscoped"
        end

        def voms_authenticate(tenant = nil)
          set_voms_unscoped_token

          if !tenant.blank?
            set_scoped_token(tenant)
          else
            get_first_working_project
          end
        end

        def set_voms_unscoped_token
          response = @env_ref.class.post(
            # egi.eu and mapped below should be configurable
            "#{@base_url}/OS-FEDERATION/identity_providers/egi.eu/protocols/mapped/auth",
          )
          Occi::Api::Log.debug response.inspect

          if response.success?
            @env_ref.class.headers['X-Auth-Token'] = response.headers['x-subject-token']
          else
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
          end
        end

        def get_first_working_project
          response = @env_ref.class.get(
            "#{@base_url}/auth/projects",
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          raise ::Occi::Api::Client::Errors::AuthnError,
                "Keystone didn't return any projects, fallback failed!" if response['projects'].blank?

          response['projects'].each do |project|
            begin
              Occi::Api::Log.debug "Authenticating for project #{project['name'].inspect}"
              set_scoped_token(project['id'])

              # found a working project, stop looking
              break
            rescue ::Occi::Api::Client::Errors::AuthnError
              # ignoring and trying the next tenant
            end
          end
        end

        def set_scoped_token(project)
          body = {
            "auth" => {
              "identity" => {
                "methods" => ["token"],
                "token" => {"id" => @env_ref.class.headers['X-Auth-Token'] }
              },
              "scope" => {
                "project" => {"id" => project}
              }
            }
          }
          response = @env_ref.class.post(
            "#{@base_url}/auth/tokens",
            :body => body.to_json,
            :headers => get_req_headers
          )

          Occi::Api::Log.debug response.inspect

          if response.success?
            @env_ref.class.headers['X-Auth-Token'] = response.headers['x-subject-token']
          else
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
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
