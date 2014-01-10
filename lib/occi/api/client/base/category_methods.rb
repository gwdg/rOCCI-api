module Occi::Api::Client
  module Base

    module CategoryMethods

      # Retrieves all available category types.
      #
      # @example
      #    client.get_category_types # => [ "entity", "resource", "link" ]
      #
      # @return [Array<String>] list of available category types in a human-readable format
      def get_category_types
        @model.categories.to_a.collect { |category| category.term }
      end

      # Retrieves all available category type identifiers.
      #
      # @example
      #    client.get_category_type_identifiers
      #    # => [ "http://schemas.ogf.org/occi/core#entity",
      #    #      "http://schemas.ogf.org/occi/core#resource",
      #    #      "http://schemas.ogf.org/occi/core#link" ]
      #
      # @return [Array<String>] list of available category type identifiers
      def get_category_type_identifiers
        @model.categories.to_a.collect { |category| category.type_identifier }
      end

      # Retrieves available category type identifier for the given category type.
      #
      # @example
      #    client.get_category_type_identifier("compute")
      #     # => 'http://schemas.ogf.org/occi/infrastructure#compute'
      #
      # @param type [String] short category type
      # @return [String, nil] category type identifier for the given category type
      def get_category_type_identifier(type)
        return type if (type =~ URI::ABS_URI) || (type && type.start_with?('/'))

        cats = @model.categories.to_a.select { |k| k.term == type }
        tis = cats.collect { |c| c.type_identifier }
        tis.uniq!

        if tis.length > 1
          raise Occi::Api::Client::Errors::AmbiguousNameError,
                "Category type #{type.inspect} is ambiguous, use a type identifier!"
        end

        tis.first
      end

    end

  end
end