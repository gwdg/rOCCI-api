# load all parts of the ClientBase
Dir[File.join(File.dirname(__FILE__), 'base', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi::Api::Client

  class ClientBase

    # a few attributes which should be visible outside the client
    attr_reader :endpoint, :auth_options, :media_type
    attr_reader :connected, :model, :logger, :last_response
    attr_reader :options

    def initialize(options = {})
      # define defaults and convert options to Hashie::Mash if necessary
      defaults = Hashie::Mash.new({
        :endpoint => "http://localhost:3000/",
        :auth => {:type => "none"},
        :log => {:out => STDERR, :level => Occi::Api::Log::WARN, :logger => nil},
        :auto_connect => true,
        :media_type => nil
      })

      options = options.marshal_dump if options.is_a?(OpenStruct)
      options = Hashie::Mash.new(options)

      @options = defaults.merge(options)

      # set Occi::Api::Log
      @logger = get_logger(@options[:log])

      # check the validity and canonize the endpoint URI
      @endpoint = get_endpoint_uri(@options[:endpoint])

      # set global connection options, such as timeout
      configure_connection(@options)

      # pass auth options
      @auth_options = get_auth(@options[:auth])

      # verify authN before attempting actual
      # message exchange with the server; this
      # is necessary because of OCCI-OS and its
      # redirect to OS Keystone
      preauthenticate

      # set accepted media types
      @media_type = get_media_type(@options[:media_type])

      @connected = false
    end

    # Issues necessary connecting operations on connection-oriented
    # clients. Stateless clients (such as ClientHttp) should use
    # the auto_connect option during instantiation.
    #
    # @example
    #    client.connect # => true
    #
    # @param force [Boolean] force re-connect on already connected client
    # @return [Boolean] true on successful connect
    def connect(force = false)
      raise "Client already connected!" if @connected && !force
      @connected = true
    end

    # include stuff
    include Occi::Api::Client::Base::Stubs

    # include action-related stuff
    include Occi::Api::Client::Base::ActionMethods

    # include category-related stuff
    include Occi::Api::Client::Base::CategoryMethods

    # include kind-related stuff
    include Occi::Api::Client::Base::KindMethods

    # include entity-related stuff
    include Occi::Api::Client::Base::EntityMethods

    # include mixin-related stuff
    include Occi::Api::Client::Base::MixinMethods

    # include helpers
    include Occi::Api::Client::Base::Helpers

    protected

    # include protected stuff
    include Occi::Api::Client::Base::ProtectedStubs
    include Occi::Api::Client::Base::ProtectedHelpers

  end

end
