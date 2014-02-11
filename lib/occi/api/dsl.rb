# load all parts of the DSL
Dir[File.join(File.dirname(__FILE__), 'dsl', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi::Api::Dsl

  def connect(protocol = :http, options = {})
    raise ArgumentError, 'Protocol is a required argument!' unless protocol

    if block_given?
      options = options.marshal_dump if options.is_a?(OpenStruct)
      options = Hashie::Mash.new(options)
      yield(options)
    end

    case protocol.to_sym
    when :http 
      @client = Occi::Api::Client::ClientHttp.new(options)
    else
      raise ArgumentError, "Protocol #{protocol.to_s} is not supported!"
    end

    @client.connect unless @client.connected

    true
  end

  # include main request methods
  include Occi::Api::Dsl::MainMethods

  # include methods converting between types and type identifiers
  include Occi::Api::Dsl::TypeMethods

  # include methods helping with mixins
  include Occi::Api::Dsl::MixinMethods

  # include general helpers, normalizers etc.
  include Occi::Api::Dsl::HelperMethods

  private

  def check
    raise RuntimeError, "You have to issue 'connect' first!" unless @client
    raise RuntimeError, "Client is disconnected!" unless @client.connected
  end

end
