require 'httparty'
#require 'persistent_httparty'

# load all parts of the ClientHttp
Dir[File.join(File.dirname(__FILE__), 'http', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi::Api::Client

  class ClientHttp < ClientBase

    # HTTParty for raw HTTP requests
    include HTTParty

    # Take advantage of persistent HTTP connections
    # TODO: currently breaks SSL w/ X.509 auth, investigate why
    #persistent_connection_adapter

    # TODO: change default Accept to JSON as soon as it is properly
    #       implemented in OpenStack's OCCI-OS
    #       'Accept' => 'application/occi+json,text/plain;q=0.8,text/occi;q=0.2'
    DEFAULT_HEADERS = {
      'Accept'     => 'text/plain,text/occi;q=0.2',
      'User-Agent' => "rOCCI-core/#{Occi::VERSION} rOCCI-api/#{Occi::Api::VERSION} OCCI/1.1 " \
                      "#{RUBY_ENGINE}-#{RUBY_PLATFORM}/#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"
    }
    headers DEFAULT_HEADERS

    # Initializes client data structures and retrieves OCCI model
    # from the server.
    #
    # @example
    #    options = {
    #      :endpoint => "http://localhost:3000/",
    #      :timeout => 15
    #      :auth => {:type => "none"},
    #      :log => {:out => STDERR, :level => Occi::Api::Log::WARN, :logger => nil},
    #      :auto_connect => true,
    #      :media_type => nil
    #    }
    #
    #    Occi::Api::Client::ClientHttp.new options # => #<Occi::Api::Client::ClientHttp>
    #
    # @param options [Hash] options, for available options and defaults see examples
    # @return [Occi::Api::Client::ClientHttp] client instance
    def initialize(options = {})
      super options

      # set a global base URI for all subsequent requests
      # must be done after authN calls
      endpoint_base_uri = "#{@endpoint.scheme}://#{@endpoint.host}"
      endpoint_base_uri << ":#{@endpoint.port}" unless @endpoint.port == @endpoint.default_port
      self.class.base_uri endpoint_base_uri

      # get model information from the endpoint
      # and create Occi::Model instance
      model_collection = get("#{@endpoint.path}/-/")
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

      headers = self.class.headers.clone
      headers['Accept'] = 'text/uri-list'

      response = self.class.get(
        path,
        :headers => headers
      )

      response_msg = response_message(response)
      raise "HTTP GET failed! #{response_msg}" unless [200, 204].include?(response.code)

      # TODO: remove the gsub OCCI-OS hack as soon as they stop using 'uri:'
      (response.body || '').gsub(/\# uri:\/(compute|storage|network)\/[\n]?/, '').split("\n").compact
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

        if @media_type == 'application/occi+json'
          # all at once
          descriptions = get(path_for_kind_type_identifier(resource_type_identifier))
        else
          # one resource at a time
          locations = list(resource_type_identifier)

          # make the requests
          locations.each do |location|
            path = sanitize_instance_link(location)
            descriptions.merge! get(path)
          end
        end
      else
        # this is a link of a specific resource (absolute or relative)
        path = sanitize_instance_link(resource_type_identifier)
        descriptions.merge! get(path)
      end

      # decide what to return, in case of mixed collections prefer resources
      if descriptions.resources.empty?
        descriptions.links
      else
        descriptions.resources
      end
    end

    # @see Occi::Api::Client::ClientBase
    def create(entity)
      raise "#{entity.class.name.inspect} not an entity!" unless entity.kind_of? Occi::Core::Entity

      Occi::Api::Log.debug "Entity kind: #{entity.kind.type_identifier.inspect}"
      raise "No kind found for #{entity.inspect}" unless entity.kind

      # get location for this kind of entity
      path = path_for_kind_type_identifier(entity.kind.type_identifier)
      collection = Occi::Collection.new

      # is this entity a Resource or a Link?
      Occi::Api::Log.debug "Entity class: #{entity.class.name.inspect}"
      collection.resources << entity if entity.kind_of? Occi::Core::Resource
      collection.links << entity if entity.kind_of? Occi::Core::Link

      # make the request
      post path, collection
    end

    # @see Occi::Api::Client::ClientBase
    def delete(resource_type_identifier)
      raise 'Resource not provided!' if resource_type_identifier.blank?
      path = path_for_kind_type_identifier(resource_type_identifier)

      Occi::Api::Log.debug("Deleting #{path.inspect} for #{resource_type_identifier.inspect}")
      del path
    end

    # @see Occi::Api::Client::ClientBase
    def trigger(resource_type_identifier, action_instance)
      raise 'Resource not provided!' if resource_type_identifier.blank?
      raise 'ActionInstance not provided!' if action_instance.blank?

      # attempt to resolve shortened identifiers
      resource_type_identifier = get_resource_type_identifier(resource_type_identifier)
      path = path_for_kind_type_identifier(resource_type_identifier)

      # prepare data
      path = "#{path}?action=#{action_instance.action.term}"
      collection = Occi::Collection.new
      collection << action_instance

      # make the request
      post path, collection
    end

    # @see Occi::Api::Client::ClientBase
    def update(resource_type_identifier, mixins)
      raise 'Resource not provided!' if resource_type_identifier.blank?
      raise 'Mixins not provided!' if mixins.blank?

      # attempt to resolve shortened identifiers
      resource_type_identifier = get_resource_type_identifier(resource_type_identifier)
      path = path_for_kind_type_identifier(resource_type_identifier)

      # prepare data
      collection = Occi::Collection.new
      collection.mixins = mixins

      # make the request
      post path, collection
    end

    # @see Occi::Api::Client::ClientBase
    def refresh
      # re-download the model from the server
      model_collection = get('/-/')
      @model = get_model(model_collection)
    end

    private

    # include HTTParty wrappers
    include Occi::Api::Client::Http::PartyWrappers

    # include various helper methods (media type stuff, authN, etc.)
    include Occi::Api::Client::Http::Helpers

    # include methods dealing with HTTP codes
    include Occi::Api::Client::Http::CodeHelpers

  end

end
