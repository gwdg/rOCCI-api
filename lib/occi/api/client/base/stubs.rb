module Occi::Api::Client
  module Base

    module Stubs

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
      # @param [String] resource type or type identifier
      # @param [Occi::Core::ActionInstance] type of action
      # @return [Boolean] status
      def trigger(resource_type_identifier, action_instance)
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

    end

  end
end