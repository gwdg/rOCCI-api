require 'httparty'

require 'occi/api/client/http/net_http_fix'
require 'occi/api/client/http/httparty_fix'
require 'occi/api/client/http/authn_utils'

module Occi
  module Api
    module Client

      class ClientHttp < ClientBase

        # HTTParty for raw HTTP requests
        include HTTParty

        # TODO: uncomment the following line as JSON is properly implemented in OpenStack
        # headers 'Accept' => 'application/occi+json,text/plain;q=0.8,text/occi;q=0.2'
        headers 'Accept' => 'text/plain,text/occi;q=0.2'

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
          model = get('/-/')
          set_model model

          # auto-connect?
          @connected = @options[:auto_connect]
        end
        
        # @see Occi::Api::Client::ClientBase
        def list(resource_type_identifier=nil)
          if resource_type_identifier
            # convert type to type identifier
            kinds = @model.kinds.select {
              |kind| kind.term == resource_type_identifier
            }
            if kinds.any?
              resource_type_identifier = kinds.first.type_identifier
            end

            raise 'Unkown resource type identifier!' unless resource_type_identifier
            unless @model.get_by_id resource_type_identifier
              raise "Resource type identifier not allowed with this model! [#{resource_type_identifier}]"
            end

            # split the type identifier and get the most important part
            uri_part = resource_type_identifier.split('#').last

            # request uri-list from the server
            path = uri_part + '/'
          end

          path = '/' unless path

          headers = self.class.headers.clone
          headers['Accept'] = 'text/uri-list'

          response = self.class.get(
            @endpoint + path,
            :headers => headers
          )

          # TODO: remove the gsub OCCI-OS hack as soon as they stop using 'uri:'
          response.body.gsub(/\# uri:\/(compute|storage|network)\/[\n]?/, '').split("\n").compact
        end

        # @see Occi::Api::Client::ClientBase
        def describe(resource_type_identifier=nil)

          # convert type to type identifier whenever possible
          if resource_type_identifier
            kinds = @model.kinds.select {
              |kind| kind.term == resource_type_identifier
            }
            if kinds.any?
              resource_type_identifier = kinds.first.type_identifier
            end
          end

          descriptions = []

          if resource_type_identifier.nil?
            # no filters, describe all available resources
            descriptions << get('/')
          elsif @model.get_by_id(resource_type_identifier)
            # we got type identifier
            # get all available resources of this type
            locations = list(resource_type_identifier)

            # make the requests
            locations.each do |location|
              descriptions << get(sanitize_resource_link(location))
            end
          elsif resource_type_identifier.start_with?(@endpoint) || resource_type_identifier.start_with?('/')
            # this is a link of a specific resource (obsolute or relative)
            descriptions << get(sanitize_resource_link(resource_type_identifier))
          else
            raise "Unkown resource type identifier! [#{resource_type_identifier}]"
          end

          descriptions
        end

        # @see Occi::Api::Client::ClientBase
        def create(entity)

          raise "#{entity} not an entity!" unless entity.kind_of? Occi::Core::Entity

          # is this entity valid?
          entity.model = @model
          entity.check

          Occi::Log.debug "Entity kind: #{entity.kind}"
          kind = entity.kind
          raise "No kind found for #{entity}" unless kind

          # get location for this kind of entity
          Occi::Log.debug "Kind location: #{entity.kind.location}"
          location = kind.location
          collection = Occi::Collection.new

          # is this entity a Resource or a Link?
          Occi::Log.debug "Entity class: #{entity.class.name}"
          collection.resources << entity if entity.kind_of? Occi::Core::Resource
          collection.links << entity if entity.kind_of? Occi::Core::Link

          # make the request
          post location, collection
        end

        # @see Occi::Api::Client::ClientBase
        def deploy(location)
          media_types = self.class.head(@endpoint).headers['accept'].to_s
          raise "File #{location} does not exist!" unless File.exist? location

          file = File.read(location)

          if location.include? '.ovf'
            if media_types.include? 'application/ovf'
              headers = self.class.headers.clone
              headers['Content-Type'] = 'application/ovf'
              self.class.post(@endpoint + '/compute/',
                              :body => file,
                              :headers => headers)
            else
              raise "Unsupported descriptor format! Server does not support OVF descriptors."
            end
          elsif location.include? '.ova'
            if media_types.include? ' application/ova '
              headers = self.class.headers.clone
              headers['Content-Type'] = 'application/ova'
              self.class.post(@endpoint + '/compute/',
                              :body => file,
                              :headers => headers)
            else
              raise "Unsupported descriptor format! Server does not support OVA descriptors."
            end
          else
            raise "Unsupported descriptor format! Only OVF or OVA files are supported."
          end
        end

        # @see Occi::Api::Client::ClientBase
        def deploy_ovf
          #
        end

        # @see Occi::Api::Client::ClientBase
        def deploy_ova
          #
        end

        # @see Occi::Api::Client::ClientBase
        def delete(resource_type_identifier)
          raise 'Resource not provided!' unless resource_type_identifier
          path = path_for_resource_type(resource_type_identifier)

          Occi::Log.debug("Deleting #{path} ...")
          del path
        end

        # @see Occi::Api::Client::ClientBase
        def trigger(resource_type_identifier, action)
          # TODO: not tested
          raise 'Resource not provided!' unless resource_type_identifier
          type_identifiers = @model.kinds.select {
            |kind| kind.term == resource_type_identifier
          }

          if type_identifiers.any?
            type_identifier = @model.kinds.select {
              |kind| kind.term == resource_type_identifier
            }.first.type_identifier

            location = @model.get_by_id(type_identifier).location
            resource_type_identifier = @endpoint + location
          end

          raise "Unknown resource identifier! #{resource_type_identifier}" unless resource_type_identifier.start_with? @endpoint

          # encapsulate the acion in a collection
          collection = Occi::Collection.new
          scheme, term = action.split(' #')
          collection.actions << Occi::Core::Action.new(scheme + '#', term)

          # make the request
          path = sanitize_resource_link(resource_type_identifier) + '?action=' + term
          post path, collection
        end

        # @see Occi::Api::Client::ClientBase
        def refresh
          # re-download the model from the server
          model = get('/-/')
          set_model model
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
        def get(path='', filter=nil)
          # remove the leading slash
          path = path.gsub(/\A\//, '')

          response = if filter
            categories = filter.categories.collect { |category| category.to_text }.join(',')
            attributes = filter.entities.collect { |entity| entity.attributes.combine.collect { |k, v| k + '=' + v } }.join(',')

            headers = self.class.headers.clone
            headers['Content-Type'] = 'text/occi'
            headers['Category'] = categories unless categories.empty?
            headers['X-OCCI-Attributes'] = attributes unless attributes.empty?

            self.class.get(@endpoint + path, :headers => headers)
          else
            self.class.get(@endpoint + path)
          end

          response_msg = response_message response
          raise "HTTP GET failed! #{response_msg}" unless response.code.between? 200, 300

          Occi::Log.debug "Response location: #{('/' + path).match(/\/.*\//).to_s}"
          kind = @model.get_by_location(('/' + path).match(/\/.*\//).to_s) if @model

          Occi::Log.debug "Response kind: #{kind}"

          if kind
            kind.related_to? Occi::Core::Resource ? entity_type = Occi::Core::Resource : entity_type = nil
            entity_type = Occi::Core::Link if kind.related_to? Occi::Core::Link
          end

          Occi::Log.debug "Parser call: #{response.content_type} #{entity_type} #{path.include?('-/')}"
          collection = Occi::Parser.parse(response.content_type, response.body, path.include?('-/'), entity_type, response.headers)

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
          # remove the leading slash
          path = path.gsub(/\A\//, '')

          headers = self.class.headers.clone
          headers['Content-Type'] = @media_type

          response = case @media_type
          when 'application/occi+json'
            self.class.post(@endpoint + path,
                            :body => collection.to_json,
                            :headers => headers)
          when 'text/occi'
            self.class.post(@endpoint + path,
                            :headers => collection.to_header.merge(headers))
          else
            self.class.post(@endpoint + path,
                            :body => collection.to_text,
                            :headers => headers)
          end

          response_msg = response_message response

          case response.code
          when 200
            collection = Occi::Parser.parse(response.header["content-type"].split(";").first, response)
            if collection.empty?
              Occi::Parser.locations(response.header["content-type"].split(";").first, response.body, response.header).first
            else
              collection.resources.first.location if collection.resources.first
            end
          when 201
            Occi::Parser.locations(response.header["content-type"].split(";").first, response.body, response.header).first
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
          # remove the leading slash
          path = path.gsub(/\A\//, '')

          headers = self.class.headers.clone
          headers['Content-Type'] = @media_type

          response = case @media_type
          when 'application/occi+json'
            self.class.post(@endpoint + path,
                            :body => collection.to_json,
                            :headers => headers)
          when 'text/occi'
            self.class.post(@endpoint + path,
                            :headers => collection.to_header.merge(headers))
          else
            self.class.post(@endpoint + path,
                            :body => collection.to_text,
                            :headers => headers)
          end

          response_msg = response_message response

          case response.code
          when 200, 201
            Occi::Parser.parse(response.header["content-type"].split(";").first, response)
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
          # remove the leading slash
          path = path.gsub(/\A\//, '')

          response = self.class.delete(@endpoint + path)

          response_msg = response_message response
          raise "HTTP DELETE failed! #{response_msg}" unless response.code.between? 200, 300

          true
        end

        # @see Occi::Api::Client::ClientBase
        def set_logger(log_options)
          super log_options

          self.class.debug_output $stderr if log_options[:level] == Occi::Log::DEBUG
        end

        # @see Occi::Api::Client::ClientBase
        def set_auth(auth_options, fallback = false)
          @auth_options = auth_options

          case @auth_options[:type]
          when "basic"
            @authn_plugin = Http::AuthnPlugins::Basic.new self, @auth_options
          when "digest"
            @authn_plugin = Http::AuthnPlugins::Digest.new self, @auth_options
          when "x509"
            @authn_plugin = Http::AuthnPlugins::X509.new self, @auth_options
          when "keystone"
            raise ::Occi::Api::Client::Errors::AuthnError, "This authN method is for fallback only!" unless fallback
            @authn_plugin = Http::AuthnPlugins::Keystone.new self, @auth_options
          when "none", nil
            @authn_plugin = Http::AuthnPlugins::Dummy.new self
          else
            raise ::Occi::Api::Client::Errors::AuthnError, "Unknown authN method [#{@auth_options[:type]}]!"
          end

          @authn_plugin.setup
        end

        # @see Occi::Api::Client::ClientBase
        def preauthenticate
          begin
            @authn_plugin.authenticate
          rescue ::Occi::Api::Client::Errors::AuthnError => e
            Occi::Log.debug e.message

            if @authn_plugin.fallbacks.any?
              @auth_options[:type] = @authn_plugin.fallbacks.first
              set_auth @auth_options, true
              @authn_plugin.authenticate
            else
              raise e
            end
          end
        end

        # @see Occi::Api::Client::ClientBase
        def set_media_type(force_type = nil)
          # force media_type if provided
          if force_type
            self.class.headers 'Accept' => force_type
            @media_type = force_type
          else
            media_types = self.class.head(@endpoint).headers['accept']
            Occi::Log.debug("Available media types: #{media_types}")
            @media_type = case media_types
            when /application\/occi\+json/
              'application/occi+json'
            else
              'text/plain'
            end
          end
        end

        # Generates a human-readable response message based on the HTTP response code.
        #
        # @example
        #    response_message self.class.delete(@endpoint + path)
        #     # =>  'HTTP Response status: [200] OK'
        #
        # @param [HTTParty::Response] HTTParty response object
        # @return [String] message
        def response_message(response)
          @last_response = response
          'HTTP Response status: [' + response.code.to_s + '] ' + reason_phrase(response.code)
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
