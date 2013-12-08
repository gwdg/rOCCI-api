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
      # @param [String] path for the GET request
      # @param [Occi::Collection] collection of filters
      # @return [Occi::Collection] parsed result of the request
      def get(path='/', filter=nil)
        # apply filters if present
        response = if filter
          categories = filter.categories.collect { |category| category.to_text }.join(',')
          attributes = filter.entities.collect { |entity| entity.attributes.combine.collect { |k, v| k + '=' + v } }.join(',')

          headers = self.class.headers.clone
          headers['Content-Type'] = 'text/occi'
          headers['Category'] = categories unless categories.empty?
          headers['X-OCCI-Attributes'] = attributes unless attributes.empty?

          self.class.get(path, :headers => headers)
        else
          self.class.get(path)
        end

        response_msg = response_message response
        raise "HTTP GET failed! #{response_msg}" unless response.code.between? 200, 300

        Occi::Log.debug "Response location: #{path.inspect}"
        kind = @model.get_by_location(path) if @model

        Occi::Log.debug "Response kind: #{kind.inspect}"

        entity_type = nil
        if kind && kind.related_to?(Occi::Core::Link)
          entity_type = Occi::Core::Link
        end

        entity_type = Occi::Core::Resource unless entity_type

        Occi::Log.debug "Parser call: #{response.content_type} #{path.include?('/-/')} #{entity_type} #{response.headers.inspect}"
        collection = Occi::Parser.parse(response.content_type, response.body, path.include?('/-/'), entity_type, response.headers)

        Occi::Log.debug "Parsed collection: empty? #{collection.empty?}"
        collection
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
      # @param [String] path for the POST request
      # @param [Occi::Collection] resource data to be POSTed
      # @return [String] URI location
      def post(path, collection)
        raise ArgumentError, "Path is a required argument!" if path.blank?

        headers = self.class.headers.clone
        headers['Content-Type'] = @media_type

        response = case @media_type
        when 'application/occi+json'
          self.class.post(path,
                          :body => collection.to_json,
                          :headers => headers)
        when 'text/occi'
          self.class.post(path,
                          :headers => collection.to_header.merge(headers))
        else
          self.class.post(path,
                          :body => collection.to_text,
                          :headers => headers)
        end

        response_msg = response_message(response)

        case response.code
        when 200
          collection = Occi::Parser.parse(response.header["content-type"].split(";").first, response.body)

          if collection.empty?
            Occi::Parser.locations(response.header["content-type"].split(";").first, response.body, response.headers).first
          else
            collection.resources.first.location if collection.resources.first
          end
        when 201
          # TODO: OCCI-OS hack, look for header Location instead of uri-list
          # This should be probably implemented in Occi::Parser.locations
          if response.header['location']
            response.header['location']
          else
            Occi::Parser.locations(response.header["content-type"].split(";").first, response.body, response.headers).first
          end
        else
          raise "HTTP POST failed! #{response_msg}"
        end
      end

      # Performs PUT requests and parses responses to collections.
      #
      # @example
      #    TODO: add examples
      #
      # @param [String] path for the PUT request
      # @param [Occi::Collection] resource data to send
      # @return [Occi::Collection] parsed result of the request
      def put(path, collection)
        raise ArgumentError, "Path is a required argument!" if path.blank?

        headers = self.class.headers.clone
        headers['Content-Type'] = @media_type

        response = case @media_type
        when 'application/occi+json'
          self.class.post(path,
                          :body => collection.to_json,
                          :headers => headers)
        when 'text/occi'
          self.class.post(path,
                          :headers => collection.to_header.merge(headers))
        else
          self.class.post(path,
                          :body => collection.to_text,
                          :headers => headers)
        end

        response_msg = response_message(response)

        case response.code
        when 200, 201
          Occi::Parser.parse(response.header["content-type"].split(";").first, response.body)
        else
          raise "HTTP POST failed! #{response_msg}"
        end
      end

      # Performs DELETE requests and returns True on success.
      #
      # @example
      #    del "/compute/65sf4g65sf4g-sf6g54sf5g-sfgsf32g3" # => true
      #
      # @param [String] path for the DELETE request
      # @param [Occi::Collection] collection of filters (currently NOT used)
      # @return [Boolean] status
      def del(path, filter=nil)
        raise ArgumentError, "Path is a required argument!" if path.blank?

        response = self.class.delete(path)

        response_msg = response_message(response)
        raise "HTTP DELETE failed! #{response_msg}" unless response.code.between? 200, 300

        true
      end

    end

  end
end