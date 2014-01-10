module Occi::Api::Client
  module Http

    module PartyWrappers

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
        response_msg = response_message response
        raise "HTTP GET failed! #{response_msg}" unless response.code == 200

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
        response_msg = response_message(response)
        raise "HTTP POST failed! #{response_msg}" unless response.code.between? 200, 201

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
        response_msg = response_message(response)

        if response.code.between? 200, 201
          Occi::Parser.parse(response.header["content-type"], response.body)
        else
          raise "HTTP POST failed! #{response_msg}"
        end
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

        response = self.class.delete(path)

        response_msg = response_message(response)
        raise "HTTP DELETE failed! #{response_msg}" unless response.code == 200

        true
      end

      private

      def get_process_response(path, response)
        Occi::Log.debug "Response from location: #{path.inspect}"
        kind = @model.get_by_location(path) if @model

        Occi::Log.debug "Response should contain kind: #{kind.inspect}"
        entity_type = nil
        if kind && kind.related_to?(Occi::Core::Link)
          entity_type = Occi::Core::Link
        end
        entity_type = Occi::Core::Resource unless entity_type

        Occi::Log.debug "Parser call: #{response.content_type} #{path.include?('/-/')} " \
                        "#{entity_type} #{response.headers.inspect}"
        collection = Occi::Parser.parse(
          response.content_type, response.body,
          path.include?('/-/'), entity_type, response.headers
        )

        Occi::Log.debug "Parsed collection: empty? #{collection.empty?}"
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
        true
      end

      def post_create(response)
        if response.code == 200
          collection = Occi::Parser.parse(
            response.header["content-type"],
            response.body
          )

          if collection.empty?
            Occi::Parser.locations(
              response.header["content-type"],
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
            response.header["content-type"],
            response.body,
            response.headers
          ).first
        end
      end

    end

  end
end