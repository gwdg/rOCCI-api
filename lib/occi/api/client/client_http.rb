require 'httparty'

require 'occi/api/client/http/net_http_fix'
require 'occi/api/client/http/httparty_fix'
require 'occi/api/client/authn_utils'
require 'occi/api/client/http/authn_plugins'

module Occi
  module Api
    module Client

      class ClientHttp < ClientBase

        # HTTParty for raw HTTP requests
        include HTTParty

        # TODO: change default Accept to JSON as soon as it is properly
        #       implemented in OpenStack's OCCI-OS
        #       'Accept' => 'application/occi+json,text/plain;q=0.8,text/occi;q=0.2'
        DEFAULT_HEADERS = {
          'Accept'     => 'text/plain,text/occi;q=0.2',
          'User-Agent' => "rOCCI HTTPClient #{Occi::Api::VERSION}"
        }
        headers DEFAULT_HEADERS

        # hash mapping HTTP response codes to human-readable messages
        HTTP_CODES = {
          "100" => "Continue",
          "101" => "Switching Protocols",
          "200" => "OK",
          "201" => "Created",
          "202" => "Accepted",
          "203" => "Non-Authoritative Information",
          "204" => "No Content",
          "205" => "Reset Content",
          "206" => "Partial Content",
          "300" => "Multiple Choices",
          "301" => "Moved Permanently",
          "302" => "Found",
          "303" => "See Other",
          "304" => "Not Modified",
          "305" => "Use Proxy",
          "307" => "Temporary Redirect",
          "400" => "Bad Request",
          "401" => "Unauthorized",
          "402" => "Payment Required",
          "403" => "Forbidden",
          "404" => "Not Found",
          "405" => "Method Not Allowed",
          "406" => "Not Acceptable",
          "407" => "Proxy Authentication Required",
          "408" => "Request Time-out",
          "409" => "Conflict",
          "410" => "Gone",
          "411" => "Length Required",
          "412" => "Precondition Failed",
          "413" => "Request Entity Too Large",
          "414" => "Request-URI Too Large",
          "415" => "Unsupported Media Type",
          "416" => "Requested range not satisfiable",
          "417" => "Expectation Failed",
          "500" => "Internal Server Error",
          "501" => "Not Implemented",
          "502" => "Bad Gateway",
          "503" => "Service Unavailable",
          "504" => "Gateway Time-out",
          "505" => "HTTP Version not supported"
        }

        # Initializes client data structures and retrieves OCCI model
        # from the server.
        #
        # @example
        #    options = {
        #      :endpoint => "http://localhost:3300/",
        #      :auth => {:type => "none"},
        #      :log => {:out => STDERR, :level => Occi::Log::WARN, :logger => nil},
        #      :auto_connect => "value", auto_connect => true,
        #      :media_type => nil
        #    }
        #
        #    Occi::Api::Client::ClientHttp.new options # => #<Occi::Api::Client::ClientHttp>
        #
        # @param [Hash] options, for available options and defaults see examples
        # @return [Occi::Api::Client::ClientHttp] client instance
        def initialize(options = {})
          super options
          
          # get model information from the endpoint
          # and create Occi::Model instance
          model_collection = get('/-/')
          @model = get_model(model_collection)

          # auto-connect?
          @connected = @options[:auto_connect]
        end
        
        # @see Occi::Api::Client::ClientBase
        def list(resource_type_identifier=nil)
          if resource_type_identifier
            resource_type_identifier = get_resource_type_identifier(resource_type_identifier)
            path = path_for_kind_type_identifier(resource_type_identifier)
          end

          path = '/' unless path
          path = "#{@endpoint.to_s}#{path}"

          headers = self.class.headers.clone
          headers['Accept'] = 'text/uri-list'

          response = self.class.get(
            path,
            :headers => headers
          )

          # TODO: remove the gsub OCCI-OS hack as soon as they stop using 'uri:'
          response.body.gsub(/\# uri:\/(compute|storage|network)\/[\n]?/, '').split("\n").compact
        end

        # @see Occi::Api::Client::ClientBase
        def describe(resource_type_identifier=nil)
          if resource_type_identifier
            resource_type_identifier = get_resource_type_identifier(resource_type_identifier)
          end

          descriptions = Occi::Collection.new

          if resource_type_identifier.blank?
            # no filters, describe all available resources
            descriptions.merge! get('/')
          elsif @model.get_by_id(resource_type_identifier)
            # we got type identifier
            # get all available resources of this type
            locations = list(resource_type_identifier)

            # make the requests
            locations.each do |location|
              path = sanitize_instance_link(location)
              descriptions.merge! get(path)
            end
          else
            # this is a link of a specific resource (absolute or relative)
            path = sanitize_instance_link(resource_type_identifier)
            descriptions.merge! get(path)
          end

          descriptions.resources
        end

        # @see Occi::Api::Client::ClientBase
        def create(entity)
          raise "#{entity.class.name.inspect} not an entity!" unless entity.kind_of? Occi::Core::Entity

          Occi::Log.debug "Entity kind: #{entity.kind.type_identifier.inspect}"
          raise "No kind found for #{entity.inspect}" unless entity.kind

          # get location for this kind of entity
          path = path_for_kind_type_identifier(entity.kind.type_identifier)
          collection = Occi::Collection.new

          # is this entity a Resource or a Link?
          Occi::Log.debug "Entity class: #{entity.class.name.inspect}"
          collection.resources << entity if entity.kind_of? Occi::Core::Resource
          collection.links << entity if entity.kind_of? Occi::Core::Link

          # make the request
          post path, collection
        end

        # @see Occi::Api::Client::ClientBase
        def deploy(location)
          raise "File #{location.inspect} does not exist!" unless File.exist? location

          file = File.read(location)

          if location.include? '.ovf'
            deploy_ovf file
          elsif location.include? '.ova'
            deploy_ova file
          else
            raise "Unsupported descriptor format! Only OVF or OVA files are supported."
          end
        end

        # @see Occi::Api::Client::ClientBase
        def deploy_ovf(descriptor)
          media_types = self.class.head(@endpoint.to_s).headers['accept'].to_s

          path = path_for_kind_type_identifier(Occi::Infrastructure::Compute.type_identifier)
          path = "#{@endpoint.to_s}#{path}"
          if media_types.include? 'application/ovf'
            headers = self.class.headers.clone
            headers['Content-Type'] = 'application/ovf'
            self.class.post(path,
                            :body => descriptor,
                            :headers => headers)
          else
            raise "Unsupported descriptor format! Server does not support OVF descriptors."
          end
        end

        # @see Occi::Api::Client::ClientBase
        def deploy_ova(descriptor)
          media_types = self.class.head(@endpoint.to_s).headers['accept'].to_s

          path = path_for_kind_type_identifier(Occi::Infrastructure::Compute.type_identifier)
          path = "#{@endpoint.to_s}#{path}"
          if media_types.include? ' application/ova '
            headers = self.class.headers.clone
            headers['Content-Type'] = 'application/ova'
            self.class.post(path,
                            :body => descriptor,
                            :headers => headers)
          else
            raise "Unsupported descriptor format! Server does not support OVA descriptors."
          end
        end

        # @see Occi::Api::Client::ClientBase
        def delete(resource_type_identifier)
          raise 'Resource not provided!' if resource_type_identifier.blank?
          path = path_for_kind_type_identifier(resource_type_identifier)

          Occi::Log.debug("Deleting #{path.inspect} for #{resource_type_identifier.inspect}")
          del path
        end

        # @see Occi::Api::Client::ClientBase
        def trigger(resource_type_identifier, action_instance)
          # TODO: not tested
          raise 'Resource not provided!' if resource_type_identifier.blank?

          #
          resource_type_identifier = get_resource_type_identifier(resource_type_identifier)
          path = path_for_kind_type_identifier(resource_type_identifier)

          # make the request
          post path, action_instance
        end

        # @see Occi::Api::Client::ClientBase
        def refresh
          # re-download the model from the server
          model_collection = get('/-/')
          @model = get_model(model_collection)
        end

        private

        # Performs GET request and parses the responses to collections.
        #
        # @example
        #    get "/-/" # => #<Occi::Collection>
        #    get "/compute/" # => #<Occi::Collection>
        #    get "/compute/fs65g4fs6g-sf54g54gsf-aa12faddf52" # => #<Occi::Collection>
        #
        # @param [String] path for the GET request
        # @param [Occi::Collection] collection of filters
        # @return [Occi::Collection] parsed result of the request
        def get(path='/', filter=nil)
          relative_path = path
          path = "#{@endpoint.to_s}#{path}"
          # apply filters if present
          response = if filter
            categories = filter.categories.collect { |category| category.to_text }.join(',')
            attributes = filter.entities.collect { |entity| entity.attributes.combine.collect { |k, v| k + '=' + v } }.join(',')

            headers = self.class.headers.clone
            headers['Content-Type'] = 'text/occi'
            headers['Category'] = categories unless categories.empty?
            headers['X-OCCI-Attributes'] = attributes unless attributes.empty?

            self.class.get(path, :headers => headers)
          else
            self.class.get(path)
          end

          response_msg = response_message response
          raise "HTTP GET failed! #{response_msg}" unless response.code.between? 200, 300

          Occi::Log.debug "Response location: #{relative_path.inspect}"
          kind = @model.get_by_location(relative_path) if @model

          Occi::Log.debug "Response kind: #{kind.inspect}"

          entity_type = nil
          if kind && kind.related_to?(Occi::Core::Link)
            entity_type = Occi::Core::Link
          end

          entity_type = Occi::Core::Resource unless entity_type

          Occi::Log.debug "Parser call: #{response.content_type} #{path.include?('/-/')} #{entity_type} #{response.headers.inspect}"
          collection = Occi::Parser.parse(response.content_type, response.body, path.include?('/-/'), entity_type, response.headers)

          Occi::Log.debug "Parsed collection: empty? #{collection.empty?}"
          collection
        end

        # Performs POST requests and returns URI locations. Resource data must be provided
        # in an Occi::Collection instance.
        #
        # @example
        #    collection = Occi::Collection.new
        #    collection.resources << entity if entity.kind_of? Occi::Core::Resource
        #    collection.links << entity if entity.kind_of? Occi::Core::Link
        #
        #    post "/compute/", collection # => "http://localhost:3300/compute/23sf4g65as-asdgsg2-sdfgsf2g"
        #    post "/network/", collection # => "http://localhost:3300/network/23sf4g65as-asdgsg2-sdfgsf2g"
        #    post "/storage/", collection # => "http://localhost:3300/storage/23sf4g65as-asdgsg2-sdfgsf2g"
        #
        # @param [String] path for the POST request
        # @param [Occi::Collection] resource data to be POSTed
        # @return [String] URI location
        def post(path, collection)
          raise ArgumentError, "Path is a required argument!" if path.blank?

          headers = self.class.headers.clone
          headers['Content-Type'] = @media_type

          path = "#{@endpoint.to_s}#{path}"

          response = case @media_type
          when 'application/occi+json'
            self.class.post(path,
                            :body => collection.to_json,
                            :headers => headers)
          when 'text/occi'
            self.class.post(path,
                            :headers => collection.to_header.merge(headers))
          else
            self.class.post(path,
                            :body => collection.to_text,
                            :headers => headers)
          end

          response_msg = response_message(response)

          case response.code
          when 200
            collection = Occi::Parser.parse(response.header["content-type"].split(";").first, response.body)

            if collection.empty?
              Occi::Parser.locations(response.header["content-type"].split(";").first, response.body, response.headers).first
            else
              collection.resources.first.location if collection.resources.first
            end
          when 201
            # TODO: OCCI-OS hack, look for header Location instead of uri-list
            # This should be probably implemented in Occi::Parser.locations
            if response.header['location']
              response.header['location']
            else
              Occi::Parser.locations(response.header["content-type"].split(";").first, response.body, response.headers).first
            end
          else
            raise "HTTP POST failed! #{response_msg}"
          end
        end

        # Performs PUT requests and parses responses to collections.
        #
        # @example
        #    TODO: add examples
        #
        # @param [String] path for the PUT request
        # @param [Occi::Collection] resource data to send
        # @return [Occi::Collection] parsed result of the request
        def put(path, collection)
          raise ArgumentError, "Path is a required argument!" if path.blank?

          headers = self.class.headers.clone
          headers['Content-Type'] = @media_type

          path = "#{@endpoint.to_s}#{path}"

          response = case @media_type
          when 'application/occi+json'
            self.class.post(path,
                            :body => collection.to_json,
                            :headers => headers)
          when 'text/occi'
            self.class.post(path,
                            :headers => collection.to_header.merge(headers))
          else
            self.class.post(path,
                            :body => collection.to_text,
                            :headers => headers)
          end

          response_msg = response_message(response)

          case response.code
          when 200, 201
            Occi::Parser.parse(response.header["content-type"].split(";").first, response.body)
          else
            raise "HTTP POST failed! #{response_msg}"
          end
        end

        # Performs DELETE requests and returns True on success.
        #
        # @example
        #    del "/compute/65sf4g65sf4g-sf6g54sf5g-sfgsf32g3" # => true
        #
        # @param [String] path for the DELETE request
        # @param [Occi::Collection] collection of filters (currently NOT used)
        # @return [Boolean] status
        def del(path, filter=nil)
          raise ArgumentError, "Path is a required argument!" if path.blank?

          response = self.class.delete("#{@endpoint.to_s}#{path}")

          response_msg = response_message(response)
          raise "HTTP DELETE failed! #{response_msg}" unless response.code.between? 200, 300

          true
        end

        # @see Occi::Api::Client::ClientBase
        def get_logger(log_options)
          logger = super(log_options)
          self.class.debug_output $stderr if logger.level == Occi::Log::DEBUG

          logger
        end

        # @see Occi::Api::Client::ClientBase
        def get_auth(auth_options, fallback = false)
          # select appropriate authN type
          case auth_options[:type]
          when "basic"
            @authn_plugin = Http::AuthnPlugins::Basic.new self, auth_options
          when "digest"
            @authn_plugin = Http::AuthnPlugins::Digest.new self, auth_options
          when "x509"
            @authn_plugin = Http::AuthnPlugins::X509.new self, auth_options
          when "keystone"
            raise ::Occi::Api::Client::Errors::AuthnError, "This authN method is for fallback only!" unless fallback
            @authn_plugin = Http::AuthnPlugins::Keystone.new self, auth_options
          when "none", nil
            @authn_plugin = Http::AuthnPlugins::Dummy.new self
          else
            raise ::Occi::Api::Client::Errors::AuthnError, "Unknown authN method [#{@auth_options[:type]}]!"
          end

          @authn_plugin.setup

          auth_options
        end

        # @see Occi::Api::Client::ClientBase
        def preauthenticate
          begin
            @authn_plugin.authenticate
          rescue ::Occi::Api::Client::Errors::AuthnError => e
            Occi::Log.debug e.message

            if @authn_plugin.fallbacks.any?
              # TODO: multiple fallbacks
              @auth_options[:original_type] = @auth_options[:type]
              @auth_options[:type] = @authn_plugin.fallbacks.first

              @auth_options = get_auth(@auth_options, true)
              @authn_plugin.authenticate
            else
              raise e
            end
          end
        end

        # @see Occi::Api::Client::ClientBase
        def get_media_type(force_type = nil)
          # force media_type if provided
          unless force_type.blank?
            self.class.headers 'Accept' => force_type
            media_type = force_type
          else
            media_types = self.class.head(@endpoint.to_s).headers['accept']

            Occi::Log.debug("Available media types: #{media_types.inspect}")
            media_type = case media_types
            when /application\/occi\+json/
              'application/occi+json'
            when /application\/occi\+xml/
              'application/occi+xml'
            when /text\/occi/
              'text/occi'
            else
              'text/plain'
            end
          end

          media_type
        end

        # Generates a human-readable response message based on the HTTP response code.
        #
        # @example
        #    response_message self.class.delete(@endpoint.to_s + path)
        #     # =>  'HTTP Response status: [200] OK'
        #
        # @param [HTTParty::Response] HTTParty response object
        # @return [String] message
        def response_message(response)
          @last_response = response
          "HTTP Response status: [#{response.code.to_s}] #{reason_phrase(response.code)}"
        end

        # Converts HTTP response codes to human-readable phrases.
        #
        # @example
        #    reason_phrase(500) # => "Internal Server Error"
        #
        # @param [Integer] HTTP response code
        # @return [String] human-readable phrase
        def reason_phrase(code)
          HTTP_CODES[code.to_s]
        end

      end

    end
  end
end
