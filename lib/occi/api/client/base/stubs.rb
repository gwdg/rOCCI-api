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
      # @param resource_type_identifier [String] resource type identifier or just type name
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
      # @param resource_type_identifier [String] resource type identifier, type name or resource location
      # @return [Occi::Core::Resources, Occi::Core::Links] list of resource or link descriptions
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
      # @param entity [Occi::Core::Entity] resource to be created on the server
      # @return [String] URI of the new resource
      def create(entity)
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
      # @param resource_type_identifier [String] resource type identifier, type name or location
      # @return [Boolean] status
      def delete(resource_type_identifier)
        raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
      end

      # Triggers given action on a specific resource.
      #
      # @example
      #    TODO: add examples
      #
      # @param resource_type_identifier [String] resource type or type identifier
      # @param action_instance [Occi::Core::ActionInstance] type of action
      # @return [Boolean] status
      def trigger(resource_type_identifier, action_instance)
        raise Occi::Api::Client::Errors::NotImplementedError, "#{__method__} is just a stub!"
      end

      # Updates given resource with the specified mixin(s).
      #
      # @example
      #    TODO: add examples
      #
      # @param resource_type_identifier [String] resource type or type identifier
      # @param mixins [Occi::Core::Mixins] collection of mixins
      # @return [Boolean] status
      def update(resource_type_identifier, mixins)
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
