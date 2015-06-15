module Occi::Api::Client
  module Base

    module ProtectedHelpers

      # Sets the logger and log levels. This allows users to pass existing logger
      # instances to the rOCCI client.
      #
      # @example
      #    get_logger { :out => STDERR, :level => Occi::Api::Log::WARN, :logger => nil }
      #
      # @param log_options [Hash] logger options
      # @return [Occi::Api::Log] instance of the logger
      def get_logger(log_options)
        unless log_options[:logger].kind_of?(Occi::Api::Log)
          logger = Occi::Api::Log.new(log_options[:out])
          logger.level = log_options[:level]
        else
          logger = log_options[:logger]
        end

        logger
      end

      # Checks whether the given endpoint URI is valid and converts it
      # to a URI instance.
      #
      # @example
      #    get_endpoint_uri "http://localhost:3300" # => #<URI::*>
      #
      # @param endpoint [String] endpoint URI in a non-canonical string
      # @return [URI] canonical endpoint URI
      def get_endpoint_uri(endpoint)
        unless endpoint =~ URI::ABS_URI
          raise "Endpoint not a valid absolute URI! #{endpoint.inspect}"
        end

        # normalize URIs, remove trailing slashes
        endpoint = URI(endpoint)
        endpoint.path = endpoint.path.gsub(/\/+/, '/').chomp('/')
        endpoint.query = nil

        endpoint
      end

      # Creates an Occi::Model from data retrieved from the server.
      #
      # @example
      #    model_collection = get('/-/')
      #    get_model model_collection # => #<Occi::Model>
      #
      # @param model_collection [Occi::Collection] parsed representation of server's model
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
