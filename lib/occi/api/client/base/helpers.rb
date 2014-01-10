module Occi::Api::Client
  module Base

    module Helpers

      # Returns the path for a given kind type identifier
      #
      # @example
      #    path_for_kind_type_identifier "http://schemas.ogf.org/occi/infrastructure#compute"
      #     # => "/compute/"
      #    path_for_kind_type_identifier "http://localhost:3300/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
      #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
      #
      # @param kind_type_identifier [String] kind type identifier
      # @return [String] 
      def path_for_kind_type_identifier(kind_type_identifier)
        raise ArgumentError,
              "Kind type identifier is a required argument!" if kind_type_identifier.blank?

        if kind_type_identifier.start_with?(@endpoint.to_s) || kind_type_identifier.start_with?('/')
          #we got an instance link
          return sanitize_instance_link(kind_type_identifier)
        end

        kind_type_id = get_kind_type_identifier(kind_type_identifier)
        unless kind_type_id
          raise ArgumentError,
                "There is no such kind type registered in the model! #{kind_type_identifier.inspect}"
        end

        kinds = @model.kinds.select { |kind| kind.type_identifier == kind_type_id }
        path_for_instance(kinds.first)
      end

      # Returns the path for a given instance, instances not providing
      # path information will raise an exception.
      #
      # @example
      #    path_for_instance Occi::Infrastructure::Network.new
      #     # => "/network/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
      #    path_for_instance Occi::Infrastructure::Compute.new
      #     # => "/compute/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
      #    path_for_instance Occi::Core::Mixin.new
      #     # => "/mixin/my_mixin/"
      #    path_for_instance Occi::Infrastructure::Storagelink.new
      #     # => "/link/storagelink/35ad4f45gsf-gsfg524s6gsfg-sfgsf4gsfg"
      #
      # @param instance [Object] instance
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
      # @param instance_link [String] string containing the full instance link
      # @return [String] extracted path, with a leading slash
      def sanitize_instance_link(instance_link)
        # everything starting with '/' is considered to be a resource path
        return instance_link if instance_link.start_with? '/'

        unless instance_link.start_with?(@endpoint.to_s)
          raise ArgumentError, "Resource link #{instance_link.inspect} is not valid!"
        end

        URI(instance_link).request_uri
      end

    end

  end
end