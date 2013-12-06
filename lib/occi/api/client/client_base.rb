module Occi
  module Api
    module Client

      class ClientBase

        # a few attributes which should be visible outside the client
        attr_reader :endpoint, :auth_options, :media_type,
                    :connected, :model, :logger, :last_response,
                    :options

        def initialize(options = {})
          defaults = {
            :endpoint => "http://localhost:3300/",
            :auth => {:type => "none"},
            :log => {:out => STDERR, :level => Occi::Log::WARN, :logger => nil},
            :auto_connect => true,
            :media_type => nil
          }

          options = options.marshal_dump if options.is_a? OpenStruct
          @options = defaults.merge(options)

          # set Occi::Log
          @logger = get_logger(@options[:log])

          # check the validity and canonize the endpoint URI
          @endpoint = get_endpoint_uri(@options[:endpoint])

          # pass auth options
          @auth_options = get_auth(@options[:auth])

          # verify authN before attempting actual
          # message exchange with the server; this
          # is necessary because of OCCI-OS and its
          # redirect to OS Keystone
          preauthenticate

          # set accepted media types
          @media_type = get_media_type(@options[:media_type])

          @connected = false
        end

        # Issues necessary connecting operations on connection-oriented
        # clients. Stateless clients (such as ClientHttp) should use
        # the auto_connect option during instantiation.
        #
        # @example
        #    client.connect # => true
        #
        # @param [Boolean] force re-connect on already connected client
        # @return [Boolean] true on successful connect
        def connect(force = false)
          raise "Client already connected!" if @connected && !force
          @connected = true
        end

        ##############################################################################
        ######## STUBS START
        ##############################################################################

        # Retrieves available resources represented by resource locations (URIs).
        # If no type identifier is specified, all available resource are listed.
        # Type identifier can be specified in its shortened format (e.g. "compute",
        # "storage", "network").
        #
        # @example
        #    client.list
        #     # => [ "http://localhost:3300/compute/jh425jhj3h413-7dj29d7djd9e3-djh2jh4j4j",
        #     #      "http://localhost:3300/network/kh425jhj3h413-7dj29d7djd9e3-djh2jh4j4j",
        #     #      "http://localhost:3300/storage/lh425jhj3h413-7dj29d7djd9e3-djh2jh4j4j" ]
        #    client.list "compute"
        #     # => [ "http://localhost:3300/compute/jh425jhj3h413-7dj29d7djd9e3-djh2jh4j4j" ]
        #    client.list "http://schemas.ogf.org/occi/infrastructure#compute"
        #     # => [ "http://localhost:3300/compute/jh425jhj3h413-7dj29d7djd9e3-djh2jh4j4j" ]
        #
        # @param [String] resource type identifier or just type name
        # @return [Array<String>] list of links
        def list(resource_type_identifier=nil)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Retrieves descriptions for available resources specified by a type
        # identifier or resource location. If no type identifier or location
        # is specified, all available resources in all available resource types
        # will be described.
        #
        # @example
        #    client.describe
        #     # => #<Occi::Core::Resources>
        #    client.describe "compute"
        #     # => #<Occi::Core::Resources>
        #    client.describe "http://schemas.ogf.org/occi/infrastructure#compute"
        #     # => #<Occi::Core::Resources>
        #    client.describe "http://localhost:3300/compute/j5hk1234jk2524-2j3j2k34jjh234-adfaf1234"
        #     # => #<Occi::Core::Resources>
        #
        # @param [String] resource type identifier, type name or resource location
        # @return [Occi::Core::Resources] list of resource descriptions
        def describe(resource_type_identifier=nil)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Creates a new resource on the server. Resource must be provided
        # as an instance of Occi::Core::Entity, e.g. instantiated using
        # the get_resource method.
        #
        # @example
        #    res = client.get_resource "compute"
        #
        #    res.title = "MyComputeResource1"
        #    res.mixins << client.get_mixin('small', "resource_tpl")
        #    res.mixins << client.get_mixin('debian6', "os_tpl")
        #
        #    client.create res # => "http://localhost:3300/compute/df7698...f987fa"
        #
        # @param [Occi::Core::Entity] resource to be created on the server
        # @return [String] URI of the new resource
        def create(entity)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Deploys a compute resource based on an OVF/OVA descriptor available
        # on a local file system.
        #
        # @example
        #    client.deploy "~/MyVMs/rOcciVM.ovf" # => "http://localhost:3300/compute/343423...42njhdafa"
        #
        # @param [String] location of an OVF/OVA file
        # @return [String] URI of the new resource
        def deploy(location)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Deploys a compute resource based on an OVF descriptor available
        # directly as a String.
        #
        # @example
        #    client.deploy_ovf "OVF DESCRIPTOR HERE" # => "http://localhost:3300/compute/343423...42njhdafa"
        #
        # @param [String] OVF descriptor (e.g., already read from a file or generated)
        # @return [String] URI of the new resource
        def deploy_ovf(descriptor)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Deploys a compute resource based on an OVA descriptor available
        # directly as a String.
        #
        # @example
        #    client.deploy_ova "OVA DESCRIPTOR HERE" # => "http://localhost:3300/compute/343423...42njhdafa"
        #
        # @param [String] OVA descriptor (e.g., already read from a file or generated)
        # @return [String] URI of the new resource
        def deploy_ova(descriptor)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Deletes a resource or all resource of a certain resource type
        # from the server.
        #
        # @example
        #    client.delete "compute" # => true
        #    client.delete "http://schemas.ogf.org/occi/infrastructure#compute" # => true
        #    client.delete "http://localhost:3300/compute/245j42594...98s9df8s9f" # => true
        #
        # @param [String] resource type identifier, type name or location
        # @return [Boolean] status
        def delete(resource_type_identifier)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Triggers given action on a specific resource.
        #
        # @example
        #    TODO: add examples
        #
        # @param [String] resource location
        # @param [String] type of action
        # @return [String] resource location
        def trigger(resource_type_identifier, action)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Refreshes the Occi::Model used inside the client. Useful for
        # updating the model without creating a new instance or
        # reconnecting. Saves a lot of time in an interactive mode.
        #
        # @example
        #    client.refresh
        def refresh
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        ##############################################################################
        ######## STUBS END
        ##############################################################################

        # Creates a new resource instance, resource should be specified
        # by its name or identifier.
        #
        # @example
        #   client.get_resource "compute" # => Occi::Core::Resource
        #   client.get_resource "storage" # => Occi::Core::Resource
        #   client.get_resource "http://schemas.ogf.org/occi/infrastructure#network"
        #    # => Occi::Core::Resource
        #
        # @param [String] resource name or resource identifier
        # @return [Occi::Core::Resource] new resource instance
        def get_resource(resource_type)
          Occi::Log.debug("Instantiating #{resource_type.inspect}")

          type_id = if @model.get_by_id resource_type
            # we got a resource type identifier
            resource_type
          else
            # we got a resource type name
            type_ids = @model.kinds.to_a.select { |kind| kind.term == resource_type }
            type_ids.any? ? type_ids.first.type_identifier : nil
          end

          raise "Unknown resource type! #{resource_type.inspect}" unless type_id

          new_resource = Occi::Core::Resource.new(type_id)
          new_resource.model = @model

          new_resource
        end

        # Retrieves all kind type identifiers related to a given type identifier
        #
        # @example
        #    client.get_kind_type_identifiers_related_to 'http://schemas.ogf.org/occi/infrastructure#network'
        #    # => [ "http://schemas.ogf.org/occi/infrastructure#network",
        #    #      "http://schemas.ogf.org/occi/infrastructure#ipnetwork" ]
        #
        # @param [String] type identifier
        # @return [Array<String>] list of available kind type identifiers related to
        #                         the given type identifier
        def get_kind_type_identifiers_related_to(type_identifier)
          Occi::Log.debug("Getting kind type identifiers related to #{type_identifier.inspect}")
          collection = @model.get(type_identifier)
          collection.kinds.to_a.collect { |kind| kind.type_identifier }
        end

        # Retrieves all available kind types.
        #
        # @example
        #    client.get_kind_types # => [ "entity", "resource", "link" ]
        #
        # @return [Array<String>] list of available kind types in a human-readable format
        def get_kind_types
          @model.kinds.to_a.collect { |kind| kind.term }
        end

        # Retrieves all available kind type identifiers.
        #
        # @example
        #    client.get_kind_type_identifiers
        #    # => [ "http://schemas.ogf.org/occi/core#entity",
        #    #      "http://schemas.ogf.org/occi/core#resource",
        #    #      "http://schemas.ogf.org/occi/core#link" ]
        #
        # @return [Array<String>] list of available kind type identifiers
        def get_kind_type_identifiers
          @model.kinds.to_a.collect { |kind| kind.type_identifier }
        end

        # Retrieves all available entity types.
        #
        # @example
        #    client.get_entity_types # => [ "entity", "resource", "link" ]
        #
        # @return [Array<String>] list of available entity types in a human-readable format
        def get_entity_types
          collection = @model.get(Occi::Core::Entity.kind.type_identifier)
          collection.kinds.to_a.collect { |kind| kind.term }
        end

        # Retrieves all available entity type identifiers.
        #
        # @example
        #    client.get_kind_type_identifiers
        #    # => [ "http://schemas.ogf.org/occi/core#entity",
        #    #      "http://schemas.ogf.org/occi/core#resource",
        #    #      "http://schemas.ogf.org/occi/core#link" ]
        #
        # @return [Array<String>] list of available entity types in a OCCI ID format
        def get_entity_type_identifiers
          get_kind_type_identifiers_related_to Occi::Core::Entity.kind.type_identifier
        end

        # Retrieves all available resource types.
        #
        # @example
        #    client.get_resource_types # => [ "compute", "storage", "network" ]
        #
        # @return [Array<String>] list of available resource types in a human-readable format
        def get_resource_types
          collection = @model.get(Occi::Core::Resource.kind.type_identifier)
          collection.kinds.to_a.collect { |kind| kind.term }
        end

        # Retrieves all available resource type identifiers.
        #
        # @example
        #    client.get_resource_type_identifiers
        #    # => [ "http://schemas.ogf.org/occi/infrastructure#compute",
        #    #      "http://schemas.ogf.org/occi/infrastructure#storage",
        #    #      "http://schemas.ogf.org/occi/infrastructure#network" ]
        #
        # @return [Array<String>] list of available resource types in a Occi ID format
        def get_resource_type_identifiers
          get_kind_type_identifiers_related_to Occi::Core::Resource.kind.type_identifier
        end

        # Retrieves all available link types.
        #
        # @example
        #    client.get_link_types # => [ "storagelink", "networkinterface" ]
        #
        # @return [Array<String>] list of available link types in a human-readable format
        def get_link_types
          collection = @model.get Occi::Core::Link.kind
          collection.kinds.to_a.collect { |kind| kind.term }
        end

        # Retrieves all available link type identifiers.
        #
        # @example
        #    client.get_link_type_identifiers
        #    # => [ "http://schemas.ogf.org/occi/infrastructure#storagelink",
        #    #      "http://schemas.ogf.org/occi/infrastructure#networkinterface" ]
        #
        # @return [Array<String>] list of available link types in a OCCI ID format
        def get_link_type_identifiers
          get_kind_type_identifiers_related_to Occi::Core::Link.kind.type_identifier
        end

        # Looks up a mixin using its name and, optionally, a type as well.
        # Will return mixin's full location (a link) or a description.
        #
        # @example
        #    client.get_mixin "debian6"
        #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
        #    client.get_mixin "debian6", "os_tpl", true
        #     # => #<Occi::Core::Mixin>
        #    client.get_mixin "large", "resource_tpl"
        #     # => "http://my.occi.service/occi/infrastructure/resource_tpl#large"
        #    client.get_mixin "debian6", "resource_tpl" # => nil
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @param [Boolean] should we describe the mixin or return its link?
        # @return [String, Occi::Core::Mixin, nil] link, mixin description or nothing found
        def get_mixin(name, type = nil, describe = false)
          # TODO: mixin fix
          Occi::Log.debug("Looking for mixin #{name} + #{type} + #{describe}")

          # TODO: extend this code to support multiple matches and regex filters
          # should we look for links or descriptions?
          describe ? describe_mixin(name, type) : list_mixin(name, type)
        end

        # Looks up a mixin using its name and, optionally, a type as well.
        # Will return mixin's full description.
        #
        # @example
        #    client.describe_mixin "debian6"
        #     # => #<Occi::Core::Mixin>
        #    client.describe_mixin "debian6", "os_tpl"
        #     # => #<Occi::Core::Mixin>
        #    client.describe_mixin "large", "resource_tpl"
        #     # => #<Occi::Core::Mixin>
        #    client.describe_mixin "debian6", "resource_tpl" # => nil
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @return [Occi::Core::Mixin, nil] mixin description or nothing found
        def describe_mixin(name, type = nil)
          mixins = get_mixins(type)

          mixins = mixins.to_a.select { |m| m.term == name }
          mixins.any? ? mixins.first : nil
        end

        # Looks up a mixin with a specific type, will return
        # mixin's full description.
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @return [Occi::Core::Mixin] mixin description
        def describe_mixin_w_type(name, type)
          describe_mixin(name, type)
        end

        # Looks up a mixin in all available mixin types, will
        # return mixin's full description. Returns always the
        # first match found, search will start in os_tpl.
        #
        # @param [String] name of the mixin
        # @return [Occi::Core::Mixin] mixin description
        def describe_mixin_wo_type(name)
          describe_mixin(name, nil)
        end

        # Looks up a mixin using its name and, optionally, a type as well.
        # Will return mixin's full location.
        #
        # @example
        #    client.list_mixin "debian6"
        #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
        #    client.list_mixin "debian6", "os_tpl"
        #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
        #    client.list_mixin "large", "resource_tpl"
        #     # => "http://my.occi.service/occi/infrastructure/resource_tpl#large"
        #    client.list_mixin "debian6", "resource_tpl" # => nil
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @return [String, nil] link or nothing found
        def list_mixin(name, type = nil)
          mixin = describe_mixin(name, type)
          mixin ? mixin.type_identifier : nil
        end

        # Retrieves available mixins of a specified type or all available
        # mixins if the type wasn't specified. Mixins are returned in the
        # form of mixin instances.
        #
        # @example
        #    client.get_mixins
        #     # => #<Occi::Core::Mixins>
        #    client.get_mixins "os_tpl"
        #     # => #<Occi::Core::Mixins>
        #    client.get_mixins "resource_tpl"
        #     # => #<Occi::Core::Mixins>
        #
        # @param [String] type of mixins
        # @return [Occi::Core::Mixins] collection of available mixins
        def get_mixins(type = nil)
          unless type.blank?
            unless get_mixin_types.include?(type) || get_mixin_type_identifiers.include?(type)
              raise ArgumentError,
                    "There is no such mixin type registered in the model! #{type.inspect}"
            end

            type = get_mixin_type_identifier(type) if get_mixin_types.include?(type)
            mixins = @model.mixins.to_a.select { |m| m.related_to?(type) }

            # drop the type mixin itself
            mixins.delete_if { |m| m.type_identifier == type }
          else
            # we did not get a type, return all mixins
            mixins = Occi::Core::Mixins.new(@model.mixins)
          end

          unless mixins.kind_of? Occi::Core::Mixins
            col = Occi::Core::Mixins.new
            mixins.each { |m| col << m }
          else
            col = mixins
          end

          col
        end

        # Retrieves available mixins of a specified type or all available
        # mixins if the type wasn't specified. Mixins are returned in the
        # form of mixin identifiers.
        #
        # @example
        #    client.list_mixins
        #     # => #<Array<String>>
        #    client.list_mixins "os_tpl"
        #     # => #<Array<String>>
        #    client.list_mixins "resource_tpl"
        #     # => #<Array<String>>
        #
        # @param [String] type of mixins
        # @return [Array<String>] collection of available mixin identifiers
        def list_mixins(type = nil)
          mixins = get_mixins(type)
          mixins.to_a.collect { |m| m.type_identifier }
        end

        # Retrieves available mixin types. Mixin types are presented
        # in a shortened format (i.e. not as type identifiers).
        #
        # @example
        #    client.get_mixin_types # => [ "os_tpl", "resource_tpl" ]
        #
        # @return [Array<String>] list of available mixin types
        def get_mixin_types
          get_mixins.to_a.collect { |m| m.term }
        end

        # Retrieves available mixin type identifiers.
        #
        # @example
        #    client.get_mixin_type_identifiers
        #     # => ['http://schemas.ogf.org/occi/infrastructure#os_tpl',
        #     #     'http://schemas.ogf.org/occi/infrastructure#resource_tpl']
        #
        # @return [Array<String>] list of available mixin type identifiers
        def get_mixin_type_identifiers
          list_mixins(nil)
        end

        # Retrieves available mixin type identifier for the given mixin type.
        #
        # @example
        #    client.get_mixin_type_identifier("os_tpl")
        #     # => 'http://schemas.ogf.org/occi/infrastructure#os_tpl'
        #
        # @return [String, nil] mixin type identifier for the given mixin type
        def get_mixin_type_identifier(type)
          mixins = get_mixins.to_a.select { |m| m.term == type }
          mixins.collect { |m| m.type_identifier }.first
        end

        # Retrieves available os_tpls from the model.
        #
        # @example
        #    get_os_templates # => #<Occi::Core::Mixins>
        #
        # @return [Occi::Core::Mixins] collection containing all registered OS templates
        def get_os_templates
          get_mixins "http://schemas.ogf.org/occi/infrastructure#os_tpl"
        end
        alias_method :get_os_tpls, :get_os_templates

        # Retrieves available resource_tpls from the model.
        #
        # @example
        #    get_resource_templates # => #<Occi::Core::Mixins>
        #
        # @return [Occi::Core::Mixins] collection containing all registered resource templates
        def get_resource_templates
          get_mixins "http://schemas.ogf.org/occi/infrastructure#resource_tpl"
        end
        alias_method :get_resource_tpls, :get_resource_templates

        # Returns the path for a given kind type identifier
        #
        # @example
        #    path_for_kind_type_identifier "http://schemas.ogf.org/occi/infrastructure#compute"
        #     # => "/compute/"
        #    path_for_kind_type_identifier "http://localhost:3300/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #
        # @param [String] kind type identifier
        # @return [String] 
        def path_for_kind_type_identifier(kind_type_identifier)
          raise ArgumentError,
                "Kind type identifier is a required argument!" if kind_type_identifier.blank?

          kinds = @model.kinds.select { |kind| kind.type_identifier == kind_type_identifier }
          if kinds.any?
            path_for_instance(kinds.first)
          elsif kind_type_identifier.start_with?(@endpoint.to_s) || kind_type_identifier.start_with?('/')
            #we got an instance link
            sanitize_instance_link(kind_type_identifier)
          else
            raise "Unknown kind identifier! #{kind_type_identifier.inspect}"
          end
        end

        # Returns the path for a given instance, instances not providing
        # path information will raise an exception.
        #
        # @example
        #    path_for_instance Occi::Infrastructure::Network.new
        #     # => "/network/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #    path_for_instance Occi::Infrastructire::Compute.new
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #    path_for_instance Occi::Core::Mixin.new
        #     # => "/mixin/my_mixin/"
        #    path_for_instance Occi::Infrastructire::Storagelink.new
        #     # => "/link/storagelink/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #
        # @param [Object] instance
        # @return [String] path for the given instance
        def path_for_instance(instance)
          unless instance.respond_to?(:location)
            raise Occi::Api::Client::Errors::TypeMismatchError,
                  "Expected an instance responding to #location, " \
                  "got #{instance.class.name.inspect}"
          end

          if instance.location.blank?
            raise Occi::Api::Client::Errors::LocationError,
                  "Instance of #{instance.class.name.inspect} has " \
                  "an empty location"
          end

          instance.location
        end

        # Extracts path from an instance link. It will remove the leading @endpoint
        # and replace it with a slash.
        #
        # @example
        #    sanitize_instance_link "http://localhost:3300/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #    sanitize_instance_link "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #
        # @param [String] string containing the full instance link
        # @return [String] extracted path, with a leading slash
        def sanitize_instance_link(instance_link)
          # everything starting with '/' is considered to be a resource path
          return instance_link if instance_link.start_with? '/'

          unless instance_link.start_with?(@endpoint.to_s)
            raise ArgumentError, "Resource link #{instance_link.inspect} is not valid!"
          end

          URI(instance_link).request_uri
        end

        protected

        ##############################################################################
        ######## STUBS START
        ##############################################################################

        # Sets auth method and appropriate httparty attributes. Supported auth methods
        # are: ["basic", "digest", "x509", "none"]
        #
        # @example
        #    get_auth { :type => "none" }
        #    get_auth { :type => "basic", :username => "123", :password => "321" }
        #    get_auth { :type => "digest", :username => "123", :password => "321" }
        #    get_auth { :type => "x509", :user_cert => "~/cert.pem",
        #                  :user_cert_password => "321", :ca_path => nil }
        #
        # @param [Hash] authentication options
        # @param [Boolean] allow fallback-only options
        # @return [Hash] transformed hash with authN information
        def get_auth(auth_options, fallback = false)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Attempts to establish a preliminary connection with the server
        # to verify provided credentials and perform fallback authN
        # if necessary. Has to be invoked after @auth_options have been set.
        def preauthenticate
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        # Sets media type. Will choose either application/occi+json or text/plain
        # based on the formats supported by the server.
        #
        # @example
        #    get_media_type # => 'application/occi+json'
        #
        # @return [String] chosen media type
        def get_media_type(force_type = nil)
          raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
        end

        ##############################################################################
        ######## STUBS END
        ##############################################################################

        # Sets the logger and log levels. This allows users to pass existing logger
        # instances to the rOCCI client.
        #
        # @example
        #    get_logger { :out => STDERR, :level => Occi::Log::WARN, :logger => nil }
        #
        # @param [Hash] logger options
        # @return [Occi::Log] instance of the logger
        def get_logger(log_options)
          unless log_options[:logger] && log_options[:logger].kind_of?(Occi::Log)
            logger = Occi::Log.new(log_options[:out])
            logger.level = log_options[:level]
          end

          logger
        end

        # Checks whether the given endpoint URI is valid and converts it
        # to a URI instance.
        #
        # @example
        #    get_endpoint_uri "http://localhost:3300" # => #<URI::*>
        #
        # @param [String] endpoint URI in a non-canonical string
        # @return [URI] canonical endpoint URI
        def get_endpoint_uri(endpoint)
          unless endpoint =~ URI::ABS_URI
            raise "Endpoint not a valid absolute URI! #{endpoint.inspect}"
          end

          URI(endpoint)
        end

        # Creates an Occi::Model from data retrieved from the server.
        #
        # @example
        #    model_collection = get('/-/')
        #    get_model model_collection # => #<Occi::Model>
        #
        # @param [Occi::Collection] parsed representation of server's model
        # @return [Occi::Model] Model instance
        def get_model(model_collection)
          # build model
          Occi::Model.new(model_collection)
        end

        # Returns mixin type identifiers for os_tpl mixins
        # in an array.
        #
        # @return [Array] array of os_tpl mixin identifiers
        def get_os_tpl_mixins_ary
          mixins = get_os_tpls
          mixins.to_a.collect { |m| m.type_identifier }
        end

        # Returns mixin type identifiers for resource_tpl mixins
        # in an array.
        #
        # @return [Array] array of resource_tpl mixin identifiers
        def get_resource_tpl_mixins_ary
          mixins = get_resource_tpls
          mixins.to_a.collect { |m| m.type_identifier }
        end

      end

    end
  end
end
