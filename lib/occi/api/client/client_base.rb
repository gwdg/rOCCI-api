module Occi
  module Api
    module Client

      class ClientBase

        # a few attributes which should be visible outside the client
        attr_reader :endpoint
        attr_reader :auth_options
        attr_reader :media_type
        attr_reader :connected
        attr_reader :model
        attr_reader :logger
        attr_reader :last_response
        attr_reader :options

        def initialize(options = {})
          defaults = {
            :endpoint => "http://localhost:3300/",
            :auth => {:type => "none"},
            :log => {:out => STDERR, :level => Occi::Log::WARN, :logger => nil},
            :auto_connect => true,
            :media_type => nil
          }

          options = options.marshal_dump if options.is_a? OpenStruct
          @options = defaults.merge options

          # set Occi::Log
          set_logger @options[:log]

          # check the validity and canonize the endpoint URI
          set_endpoint @options[:endpoint]

          # pass auth options
          set_auth @options[:auth]

          # verify authN before attempting actual
          # message exchange with the server; this
          # is necessary because of OCCI-OS and its
          # redirect to OS Keystone
          preauthenticate

          # set accepted media types
          set_media_type @options[:media_type]

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
        def list(resource_type_identifier=nil); end

        # Retrieves descriptions for available resources specified by a type
        # identifier or resource location. If no type identifier or location
        # is specified, all available resources in all available resource types
        # will be described.
        #
        # @example
        #    client.describe
        #     # => [#<Occi::Collection>, #<Occi::Collection>, #<Occi::Collection>]
        #    client.describe "compute"
        #     # => [#<Occi::Collection>, #<Occi::Collection>, #<Occi::Collection>]
        #    client.describe "http://schemas.ogf.org/occi/infrastructure#compute"
        #     # => [#<Occi::Collection>, #<Occi::Collection>, #<Occi::Collection>]
        #    client.describe "http://localhost:3300/compute/j5hk1234jk2524-2j3j2k34jjh234-adfaf1234"
        #     # => [#<Occi::Collection>]
        #
        # @param [String] resource type identifier, type name or resource location
        # @return [Array<Occi::Collection>] list of resource descriptions
        def describe(resource_type_identifier=nil); end

        # Creates a new resource on the server. Resource must be provided
        # as an instance of Occi::Core::Entity, e.g. instantiated using
        # the get_resource method.
        #
        # @example
        #    res = client.get_resource "compute"
        #
        #    res.title = "MyComputeResource1"
        #    res.mixins << client.find_mixin('small', "resource_tpl")
        #    res.mixins << client.find_mixin('debian6', "os_tpl")
        #
        #    client.create res # => "http://localhost:3300/compute/df7698...f987fa"
        #
        # @param [Occi::Core::Entity] resource to be created on the server
        # @return [String] URI of the new resource
        def create(entity); end

        # Deploys a compute resource based on an OVF/OVA descriptor available
        # on a local file system.
        #
        # @example
        #    client.deploy "~/MyVMs/rOcciVM.ovf" # => "http://localhost:3300/compute/343423...42njhdafa"
        #
        # @param [String] location of an OVF/OVA file
        # @return [String] URI of the new resource
        def deploy(location); end

        # Deploys a compute resource based on an OVF descriptor available
        # directly as a String.
        #
        # @example
        #    client.deploy "OVF DESCRIPTOR HERE" # => "http://localhost:3300/compute/343423...42njhdafa"
        #
        # @param [String] OVF descriptor (e.g., already read from a file or generated)
        # @return [String] URI of the new resource
        def deploy_ovf; end

        # Deploys a compute resource based on an OVA descriptor available
        # directly as a String.
        #
        # @example
        #    client.deploy "OVA DESCRIPTOR HERE" # => "http://localhost:3300/compute/343423...42njhdafa"
        #
        # @param [String] OVA descriptor (e.g., already read from a file or generated)
        # @return [String] URI of the new resource
        def deploy_ova; end

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
        def delete(resource_type_identifier); end

        # Triggers given action on a specific resource.
        #
        # @example
        #    TODO: add examples
        #
        # @param [String] resource location
        # @param [String] type of action
        # @return [String] resource location
        def trigger(resource_type_identifier, action); end

        # Refreshes the Occi::Model used inside the client. Useful for
        # updating the model without creating a new instance or
        # reconnecting. Saves a lot of time in an interactive mode.
        #
        # @example
        #    client.refresh
        def refresh; end

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

          Occi::Log.debug("Instantiating #{resource_type} ...")

          type_id = nil
          if @model.get_by_id resource_type
            # we got a resource type identifier
            type_id = resource_type
          else
            # we got a resource type name
            type_ids = @model.kinds.select { |kind| kind.term == resource_type }
            type_id = type_ids.first.type_identifier if type_ids.any?
          end

          raise "Unknown resource type! [#{resource_type}]" unless type_id

          Occi::Core::Resource.new type_id
        end

        # Retrieves all entity type identifiers related to a given type identifier
        #
        # @example
        #    client.get_entity_type_identifiers_related_to 'network'
        #    # => [ "http://schemas.ogf.org/occi/infrastructure#network",
        #    #      "http://schemas.ogf.org/occi/infrastructure#ipnetwork" ]
        #
        # @param [String] type_identifier
        # @return [Array<String>] list of available entity type identifiers related to
        #                         given type identifier in a human-readable format
        def get_entity_types_related_to(type_identifier)
          Occi::Log.debug("Getting entity type identifiers related to #{type_identifier}")
          collection = @model.get type_identifier
          collection.kinds.collect { |kind| kind.type_identifier }
        end

        # Retrieves all available entity types.
        #
        # @example
        #    client.get_entity_types # => [ "entity", "resource", "link" ]
        #
        # @return [Array<String>] list of available entity types in a human-readable format
        def get_entity_types
          Occi::Log.debug("Getting entity types ...")
          @model.kinds.collect { |kind| kind.term }
        end

        # Retrieves all available entity type identifiers.
        #
        # @example
        #    client.get_entity_type_identifiers
        #    # => [ "http://schemas.ogf.org/occi/core#entity",
        #    #      "http://schemas.ogf.org/occi/core#resource",
        #    #      "http://schemas.ogf.org/occi/core#link" ]
        #
        # @return [Array<String>] list of available entity types in a OCCI ID format
        def get_entity_type_identifiers
          get_entity_types_related_to Occi::Core::Entity.kind.type_identifier
        end

        # Retrieves all available resource types.
        #
        # @example
        #    client.get_resource_types # => [ "compute", "storage", "network" ]
        #
        # @return [Array<String>] list of available resource types in a human-readable format
        def get_resource_types
          Occi::Log.debug("Getting resource types ...")
          collection = @model.get Occi::Core::Resource.kind
          collection.kinds.collect { |kind| kind.term }
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
          get_entity_types_related_to Occi::Core::Resource.kind.type_identifier
        end

        # Retrieves all available link types.
        #
        # @example
        #    client.get_link_types # => [ "storagelink", "networkinterface" ]
        #
        # @return [Array<String>] list of available link types in a human-readable format
        def get_link_types
          Occi::Log.debug("Getting link types ...")
          collection = @model.get Occi::Core::Link.kind
          collection.kinds.collect { |kind| kind.term }
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
          get_entity_types_related_to Occi::Core::Link.kind.type_identifier
        end

        # Looks up a mixin using its name and, optionally, a type as well.
        # Will return mixin's full location (a link) or a description.
        #
        # @example
        #    client.find_mixin "debian6"
        #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
        #    client.find_mixin "debian6", "os_tpl", true
        #     # => #<Occi::Collection>
        #    client.find_mixin "large", "resource_tpl"
        #     # => "http://my.occi.service/occi/infrastructure/resource_tpl#large"
        #    client.find_mixin "debian6", "resource_tpl" # => nil
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @param [Boolean] should we describe the mixin or return its link?
        # @return [String, Occi::Collection, nil] link, mixin description or nothing found
        def find_mixin(name, type = nil, describe = false)

          Occi::Log.debug("Looking for mixin #{name} + #{type} + #{describe}")

          # is type valid?
          raise "Unknown mixin type! [#{type}]" if type && !@mixins.has_key?(type.to_sym)

          # TODO: extend this code to support multiple matches and regex filters
          # should we look for links or descriptions?
          if describe
            # we are looking for descriptions
            find_mixin_describe name, type
          else
            # we are looking for links
            find_mixin_list name, type
          end
        end

        # Looks up a mixin using its name and, optionally, a type as well.
        # Will return mixin's full description.
        #
        # @example
        #    client.find_mixin "debian6"
        #     # => #<Occi::Collection>
        #    client.find_mixin "debian6", "os_tpl"
        #     # => #<Occi::Collection>
        #    client.find_mixin "large", "resource_tpl"
        #     # => #<Occi::Collection>
        #    client.find_mixin "debian6", "resource_tpl" # => nil
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @return [Occi::Collection, nil] mixin description or nothing found
        def find_mixin_describe(name, type = nil)
          found_ary = []

          if type
            # get the first match from either os_tpls or resource_tpls
            case type
            when "os_tpl"
              found_ary = get_os_templates.select { |mixin| mixin.term == name }
            when "resource_tpl"
              found_ary = get_resource_templates.select { |template| template.term == name }
            else
              # TODO: should raise an Error?
            end
          else
            # try in os_tpls first
            found_ary = get_os_templates.select { |os| os.term == name }

            # then try in resource_tpls

            found_ary = get_resource_templates.select {
              |template| template.term == name
            } unless found_ary.any?
          end

          found_ary.any? ? found_ary.first : nil
        end

        # Looks up a mixin using its name and, optionally, a type as well.
        # Will return mixin's full location.
        #
        # @example
        #    client.find_mixin "debian6"
        #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
        #    client.find_mixin "debian6", "os_tpl"
        #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
        #    client.find_mixin "large", "resource_tpl"
        #     # => "http://my.occi.service/occi/infrastructure/resource_tpl#large"
        #    client.find_mixin "debian6", "resource_tpl" # => nil
        #
        # @param [String] name of the mixin
        # @param [String] type of the mixin
        # @return [String, nil] link or nothing found
        def find_mixin_list(name, type = nil)
          # prefix mixin name with '#' to simplify the search
          mxns = []
          name_rev = "##{name}".reverse

          if type
            # return the first match with the selected type
            mxns = @mixins[type.to_sym].select {
              |mixin| mixin.to_s.reverse.start_with? name_rev
            }
          else
            # there is no type preference, return first global match
            mxns = @mixins.flatten(2).select {
              |mixin| mixin.to_s.reverse.start_with? name_rev
            }
          end

          mxns.any? ? mxns.first : nil
        end

        # Retrieves available mixins of a specified type or all available
        # mixins if the type wasn't specified. Mixins are returned in the
        # form of mixin identifiers.
        #
        # @example
        #    client.get_mixins
        #     # => ["http://my.occi.service/occi/infrastructure/os_tpl#debian6",
        #     #     "http://my.occi.service/occi/infrastructure/resource_tpl#small"]
        #    client.get_mixins "os_tpl"
        #     # => ["http://my.occi.service/occi/infrastructure/os_tpl#debian6"]
        #    client.get_mixins "resource_tpl"
        #     # => ["http://my.occi.service/occi/infrastructure/resource_tpl#small"]
        #
        # @param [String] type of mixins
        # @return [Array<String>] list of available mixins
        def get_mixins(type = nil)
          if type
            # is type valid?
            raise "Unknown mixin type! #{type}" unless @mixins.has_key? type.to_sym

            # return mixin of the selected type
            @mixins[type.to_sym]
          else
            # we did not get a type, return all mixins
            mixins = []

            # flatten the hash and remove its keys
            get_mixin_types.each do |ltype|
              mixins.concat @mixins[ltype.to_sym]
            end

            mixins
          end
        end

        # Retrieves available mixin types. Mixin types are presented
        # in a shortened format (i.e. not as type identifiers).
        #
        # @example
        #    client.get_mixin_types # => [ "os_tpl", "resource_tpl" ]
        #
        # @return [Array<String>] list of available mixin types
        def get_mixin_types
          @mixins.keys.map { |k| k.to_s }
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
          identifiers = []

          get_mixin_types.each do |mixin_type|
            identifiers << 'http://schemas.ogf.org/occi/infrastructure#' + mixin_type
          end

          identifiers
        end

        # Retrieves available os_tpls from the model.
        #
        # @example
        #    get_os_templates # => #<Occi::Collection>
        #
        # @return [Occi::Collection] collection containing all registered OS templates
        def get_os_templates
          @model.get.mixins.select { |mixin| mixin.related.select { |rel| rel.end_with? 'os_tpl' }.any? }
        end

        # Retrieves available resource_tpls from the model.
        #
        # @example
        #    get_resource_templates # => #<Occi::Collection>
        #
        # @return [Occi::Collection] collection containing all registered resource templates
        def get_resource_templates
          @model.get.mixins.select { |mixin| mixin.related.select { |rel| rel.end_with? 'resource_tpl' }.any? }
        end

        # Creates a link of a specified kind and binds it to the given resource.
        #
        # @example
        #    link_kind = 'http://schemas.ogf.org/occi/infrastructure#storagelink'
        #    compute = client.get_resource "compute"
        #    storage_location = "http://localhost:3300/storage/321df21adfad-f3adfa5f4adf-a3d54ffadffe"
        #    linked_resource_kind = 'http://schemas.ogf.org/occi/infrastructure#storage'
        #
        #    link link_kind, compute, storage_location, linked_resource_kind
        #
        # @param [String] link type identifier (link kind)
        # @param [Occi::Core::Resource] resource to link to
        # @param [URI, String] resource to be linked
        # @param [String] type identifier of the linked resource
        # @param [Occi::Core::Attributes] link attributes
        # @param [Array<String>] link mixins
        # @return [Occi::Core::Link] link instance
        def link(kind, source, target_location, target_kind, attributes=Occi::Core::Attributes.new, mixins=[])
          link = Occi::Core::Link.new(kind)
          link.mixins = mixins
          link.attributes = attributes
          link.target = (target_location.kind_of? URI::Generic) ? target_location.path : target_location.to_s
          link.rel = target_kind

          link.check @model
          source.links << link

          link
        end

        # Returns the path for a given resource type identifier
        #
        # @example
        #    path_for_resource_type "http://schemas.ogf.org/occi/infrastructure#compute"
        #     # => "/compute/"
        #    path_for_resource_type "http://localhost:3300/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #
        # @param [String] resource type identifier
        # @return [String] 
        def path_for_resource_type(resource_type_identifier)
          return "/" if resource_type_identifier.nil? || resource_type_identifier == "/"

          kinds = @model.kinds.select { |kind| kind.term == resource_type_identifier }
          if kinds.any?
            #we got an type identifier
            path = "/" + kinds.first.type_identifier.split('#').last + "/"
          elsif resource_type_identifier.start_with?(@endpoint) || resource_type_identifier.start_with?('/')
            #we got an resource link
            path = sanitize_resource_link(resource_type_identifier)
          else
            raise "Unknown resource identifier! #{resource_type_identifier}"
          end
        end

        # Extracts the resource path from a resource link. It will remove the leading @endpoint
        # and replace it with a slash.
        #
        # @example
        #    sanitize_resource_link "http://localhost:3300/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #    sanitize_resource_link "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
        #
        # @param [String] string containing the full resource link
        # @return [String] extracted path, with a leading slash
        def sanitize_resource_link(resource_link)
          # everything starting with '/' is considered to be a resource path
          return resource_link if resource_link.start_with? '/'

          raise "Resource link #{resource_link} is not valid!" unless resource_link.start_with? @endpoint

          resource_link.gsub @endpoint, '/'
        end

        protected

        # Sets auth method and appropriate httparty attributes. Supported auth methods
        # are: ["basic", "digest", "x509", "none"]
        #
        # @example
        #    set_auth { :type => "none" }
        #    set_auth { :type => "basic", :username => "123", :password => "321" }
        #    set_auth { :type => "digest", :username => "123", :password => "321" }
        #    set_auth { :type => "x509", :user_cert => "~/cert.pem",
        #                  :user_cert_password => "321", :ca_path => nil }
        #
        # @param [Hash] authentication options
        # @param [Boolean] allow fallback-only options
        def set_auth(auth_options, fallback = false); end

        # Attempts to establish a preliminary connection with the server
        # to verify provided credentials and perform fallback authN
        # if necessary. Has to be invoked after set_auth
        def preauthenticate; end

        # Sets media type. Will choose either application/occi+json or text/plain
        # based on the formats supported by the server.
        #
        # @example
        #    set_media_type # => 'application/occi+json'
        #
        # @return [String] chosen media type
        def set_media_type(force_type = nil); end

        # Sets the logger and log levels. This allows users to pass existing logger
        # instances to the rOCCI client.
        #
        # @example
        #    set_logger { :out => STDERR, :level => Occi::Log::WARN, :logger => nil }
        #
        # @param [Hash] logger options
        def set_logger(log_options)
          if log_options[:logger].nil? || (not log_options[:logger].kind_of? Occi::Log)
            @logger = Occi::Log.new(log_options[:out])
            @logger.level = log_options[:level]
          end
        end

        # Checks whether the given endpoint URI is valid and adds a trailing
        # slash if necessary.
        #
        # @example
        #    set_endpoint "http://localhost:3300" # => "http://localhost:3300/"
        #
        # @param [String] endpoint URI in a non-canonical string
        # @return [String] canonical endpoint URI in a string, with a trailing slash
        def set_endpoint(endpoint)
          raise 'Endpoint not a valid URI' if (endpoint =~ URI::ABS_URI).nil?
          @endpoint = endpoint.chomp('/') + '/'
        end

        # Creates an Occi::Model from data retrieved from the server.
        #
        # @example
        #    model = get('/-/')
        #    set_model model # => #<Occi::Model>
        #
        # @param [Occi::Collection] parsed representation of server's model
        # @return [Occi::Model] Model instance
        def set_model(model)
          # build model
          @model = Occi::Model.new(model)

          @mixins = {
            :os_tpl => get_os_tpl_mixins_ary,
            :resource_tpl => get_res_tpl_mixins_ary
          }

          @model
        end

        #
        #
        #
        def get_os_tpl_mixins_ary
          os_tpls = []

          get_os_templates.each do |os_tpl|
            unless os_tpl.nil? || os_tpl.type_identifier.nil?
              tid = os_tpl.type_identifier.strip
              os_tpls << tid unless tid.empty?
            end
          end

          os_tpls
        end

        #
        #
        #
        def get_res_tpl_mixins_ary
          res_tpls = []

          get_resource_templates.each do |res_tpl|
            unless res_tpl.nil? || res_tpl.type_identifier.nil?
              tid = res_tpl.type_identifier.strip
              res_tpls << tid unless tid.empty?
            end
          end

          res_tpls
        end

      end

    end
  end
end
