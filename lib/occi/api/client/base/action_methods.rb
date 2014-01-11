module Occi::Api::Client
  module Base

    module ActionMethods

      # Retrieves all available action types.
      #
      # @example
      #    client.get_action_types # => [ "stop", "start", "up", "down" ]
      #
      # @return [Array<String>] list of available action types in a human-readable format
      def get_action_types
        @model.actions.to_a.collect { |action| action.term }
      end

      # Retrieves all available action type identifiers.
      #
      # @example
      #    client.get_action_type_identifiers
      #    # => [ "http://schemas.ogf.org/occi/infrastructure/compute/action#start",
      #    #      "http://schemas.ogf.org/occi/infrastructure/compute/action#stop",
      #    #      "http://schemas.ogf.org/occi/infrastructure/compute/action#suspend" ]
      #
      # @return [Array<String>] list of available action type identifiers
      def get_action_type_identifiers
        @model.actions.to_a.collect { |action| action.type_identifier }
      end

      # Retrieves available action type identifier for the given action type.
      #
      # @example
      #    client.get_action_type_identifier("start")
      #     # => 'http://schemas.ogf.org/occi/infrastructure/compute/action#start'
      #    client.get_action_type_identifier("start", "compute")
      #     # => 'http://schemas.ogf.org/occi/infrastructure/compute/action#start'
      #    client.get_action_type_identifier("start", "storage")
      #     # => nil
      #
      # @param type [String] short action type
      # @param for_kind_w_term [String] kind the action belongs to (e.g. "compute", "network", ...)
      # @return [String, nil] action type identifier for the given action type
      def get_action_type_identifier(type, for_kind_w_term = nil)
        return type if (type =~ URI::ABS_URI) || (type && type.start_with?('/'))

        acts = @model.actions.to_a.select { |k| k.term == type }
        tis = acts.collect { |c| c.type_identifier }
        tis.uniq!

        tis.keep_if { |ti| ti.include? "/#{for_kind_w_term}/" } unless for_kind_w_term.blank?

        if tis.length > 1
          raise Occi::Api::Client::Errors::AmbiguousNameError,
                "Action type #{type.inspect} is ambiguous, use a type identifier!"
        end

        tis.first
      end

    end

  end
end