module Occi::Api::Client
  module Base

    module KindMethods

      # Retrieves all kind type identifiers related to a given type identifier
      #
      # @example
      #    client.get_kind_type_identifiers_related_to 'http://schemas.ogf.org/occi/infrastructure#network'
      #    # => [ "http://schemas.ogf.org/occi/infrastructure#network",
      #    #      "http://schemas.ogf.org/occi/infrastructure#ipnetwork" ]
      #
      # @param type_identifier [String] type identifier
      # @return [Array<String>] list of available kind type identifiers related to
      #                         the given type identifier
      def get_kind_type_identifiers_related_to(type_identifier)
        Occi::Api::Log.debug("Getting kind type identifiers related to #{type_identifier.inspect}")
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

      # Retrieves available kind type identifier for the given kind type.
      #
      # @example
      #    client.get_kind_type_identifier("compute")
      #     # => 'http://schemas.ogf.org/occi/infrastructure#compute'
      #
      # @param type [String] short kind type
      # @return [String, nil] kind type identifier for the given kind type
      def get_kind_type_identifier(type)
        return type if (type =~ URI::ABS_URI) || (type && type.start_with?('/'))

        kinds = @model.kinds.to_a.select { |k| k.term == type }
        tis = kinds.collect { |k| k.type_identifier }
        tis.uniq!

        if tis.length > 1
          raise Occi::Api::Client::Errors::AmbiguousNameError,
                "Kind type #{type.inspect} is ambiguous, use a type identifier!"
        end

        tis.first
      end

    end

  end
end