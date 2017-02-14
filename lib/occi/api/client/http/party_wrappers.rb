module Occi::Api::Client
  module Http

    module PartyWrappers

      # Acceptable responses indicating OK
      OK_RANGE = [200, 201, 202, 204].freeze

      # Performs GET request and parses the responses to collections.
      #
      # @example
      #    get "/-/" # => #<Occi::Collection>
      #    get "/compute/" # => #<Occi::Collection>
      #    get "/compute/fs65g4fs6g-sf54g54gsf-aa12faddf52" # => #<Occi::Collection>
      #
      # @param path [String] path for the GET request
      # @param filter [Occi::Collection] collection of filters
      # @return [Occi::Collection] parsed result of the request
      def get(path='/', filter=nil)
        raise ArgumentError, "Path is a required argument!" if path.blank?

        # apply filters if present
        headers = self.class.headers.clone
        unless filter.blank?
          categories = filter.categories.to_a.collect { |category| category.to_string_short }.join(',')
          attributes = filter.entities.to_a.collect { |entity| entity.attributes.to_header }.join(',')

          headers['Content-Type'] = 'text/occi'
          headers['Category'] = categories unless categories.empty?
          headers['X-OCCI-Attribute'] = attributes unless attributes.empty?
        end

        response = self.class.get(path, :headers => headers)
        report_failure(response)

        get_process_response(path, response)
      end

      # Performs POST requests and returns URI locations. Resource data must be provided
      # in an Occi::Collection instance.
      #
      # @example
      #    collection = Occi::Collection.new
      #    collection.resources << entity if entity.kind_of? Occi::Core::Resource
      #    collection.links << entity if entity.kind_of? Occi::Core::Link
      #
      #    post "/compute/", collection # => "http://localhost:3300/compute/23sf4g65as-asdgsg2-sdfgsf2g"
      #    post "/network/", collection # => "http://localhost:3300/network/23sf4g65as-asdgsg2-sdfgsf2g"
      #    post "/storage/", collection # => "http://localhost:3300/storage/23sf4g65as-asdgsg2-sdfgsf2g"
      #
      # @param path [String] path for the POST request
      # @param collection [Occi::Collection] resource data to be POSTed
      # @return [Occi::Collection, String, Boolean] Collection, URI location or action result (if ActionInstance is passed)
      def post(path, collection)
        raise ArgumentError, "Path is a required argument!" if path.blank?
        raise ArgumentError, "Collection is a required argument!" if collection.blank?

        response = send_coll_request(path, collection)
        report_failure(response)

        collection.send(:standalone_action_instance?) ? post_action(response) : post_create(response)
      end

      # Performs PUT requests and parses responses to collections.
      #
      # @example
      #    TODO: add examples
      #
      # @param path [String] path for the PUT request
      # @param collection [Occi::Collection] resource data to send
      # @return [Occi::Collection] parsed result of the request
      def put(path, collection)
        raise ArgumentError, "Path is a required argument!" if path.blank?
        raise ArgumentError, "Collection is a required argument!" if collection.blank?

        response = send_coll_request(path, collection, :put)
        report_failure(response)

        Occi::Parser.parse(response.content_type, response.body)
      end

      # Performs DELETE requests and returns True on success.
      #
      # @example
      #    del "/compute/65sf4g65sf4g-sf6g54sf5g-sfgsf32g3" # => true
      #
      # @param path [String] path for the DELETE request
      # @param filter [Occi::Collection] collection of filters (currently NOT used)
      # @return [Boolean] status
      def del(path, filter=nil)
        raise ArgumentError, "Path is a required argument!" if path.blank?
        report_failure(self.class.delete(path))

        true
      end

      private

      def get_process_response(path, response)
        Occi::Api::Log.debug "Response from location: #{path.inspect}"
        kind = @model.get_by_location(path) if @model

        Occi::Api::Log.debug "Response should contain kind: #{kind ? kind.type_identifier.inspect : 'none'}"
        entity_type = if kind && kind.related_to?(Occi::Core::Link.kind)
          Occi::Core::Link
        else
          Occi::Core::Resource
        end

        Occi::Api::Log.debug "Parser call: #{response.content_type.inspect} #{path.include?('/-/')} " \
                        "#{entity_type} #{response.headers.inspect}"
        collection = Occi::Parser.parse(
          response.content_type, response.body,
          path.include?('/-/'), entity_type, response.headers
        )

        Occi::Api::Log.debug "Parsed collection: empty? #{collection.empty?}"
        collection
      end

      def send_coll_request(path, collection, type = :post)
        type ||= :post
        raise ArgumentError, "Unsupported send " \
                             "type #{type.to_s.inspect}!" unless [:post, :put].include?(type)

        headers = self.class.headers.clone
        headers['Content-Type'] = @media_type

        case @media_type
        when 'application/occi+json'
          self.class.send type,
                          path,
                          :body => collection.to_json,
                          :headers => headers
        when 'text/occi'
          self.class.send type,
                          path,
                          :headers => collection.to_header.merge(headers)
        else
          self.class.send type,
                          path,
                          :body => collection.to_text,
                          :headers => headers
        end
      end

      def post_action(response)
        coll = Occi::Parser.parse(response.content_type, response.body, true)
        coll.mixins.any? ? coll.mixins : true
      end

      def post_create(response)
        if response.code == 200
          collection = Occi::Parser.parse(
            response.content_type,
            response.body
          )

          if collection.empty?
            Occi::Parser.locations(
              response.content_type,
              response.body,
              response.headers
            ).first
          else
            raise "HTTP POST response does not " \
                  "contain required resource rendering!" unless collection.resources.first
            collection.resources.first.location
          end
        else
          Occi::Parser.locations(
            response.content_type,
            response.body,
            response.headers
          ).first
        end
      end

      def report_failure(response)
        # Is there something to report?
        return if OK_RANGE.include? response.code

        # get a human-readable response message
        response_msg = response_message(response)

        # include a Request ID if it is available
        if response.headers["x-request-id"]
          message = "#{response.request.http_method} with " \
                    "ID[#{response.headers["x-request-id"].inspect}] failed! " \
                    "#{response_msg} : #{response.body.inspect}"
        else
          message = "#{response.request.http_method} failed! " \
                    "#{response_msg} : #{response.body.inspect}"
        end

        raise message
      end

    end

  end
end
