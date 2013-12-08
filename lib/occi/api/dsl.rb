module Occi::Api::Dsl

  def connect(protocol, *args)

    case protocol
    when :http 
      @client = Occi::Api::Client::ClientHttp.new(*args)
    else
      raise "Protocol #{protocol.to_s} is not supported!"
    end

    true
  end

  def list(*args)
    check
    @client.list(*args)
  end

  def describe(*args)
    check
    @client.describe(*args)
  end

  def create(*args)
    check
    @client.create(*args)
  end

  def delete(*args)
    check
    @client.delete(*args)
  end

  def trigger(*args)
    check
    @client.trigger(*args)
  end

  def refresh
    check
    @client.refresh
  end

  def model
    check
    @client.model
  end

  ###

  def kind_types
    check
    @client.get_kind_types
  end

  def kind_type_identifier(*args)
    check
    @client.get_kind_type_identifier(*args)
  end

  def kind_type_identifiers
    check
    @client.get_kind_type_identifiers
  end

  def kind_type_identifiers_related_to(*args)
    check
    @client.get_kind_type_identifiers_related_to(*args)
  end

  def category_types
    check
    @client.get_category_types
  end

  def category_type_identifier(*args)
    check
    @client.get_category_type_identifier(*args)
  end

  def category_type_identifiers
    check
    @client.get_category_type_identifiers
  end

  def resource_types
    check
    @client.get_resource_types
  end

  def resource_type_identifier(*args)
    check
    @client.get_resource_type_identifier(*args)
  end

  def resource_type_identifiers
    check
    @client.get_resource_type_identifiers
  end

  def mixin_types
    check
    @client.get_mixin_types
  end

  def mixin_type_identifier(*args)
    check
    @client.get_mixin_type_identifier(*args)
  end

  def mixin_type_identifiers
    check
    @client.get_mixin_type_identifiers
  end

  def entity_types
    check
    @client.get_entity_types
  end

  def entity_type_identifier(*args)
    check
    @client.get_entity_type_identifier(*args)
  end

  def entity_type_identifiers
    check
    @client.get_entity_type_identifiers
  end

  def link_types
    check
    @client.get_link_types
  end

  def link_type_identifier(*args)
    check
    @client.get_link_type_identifier(*args)
  end

  def link_type_identifiers
    check
    @client.get_link_type_identifiers
  end

  ###

  def mixins(*args)
    check
    @client.get_mixins(*args)
  end

  def os_templates
    check
    @client.get_os_templates
  end

  def resource_templates
    check
    @client.get_resource_templates
  end

  def mixin_list(*args)
    check
    @client.list_mixins(*args)
  end

  def resource(*args)
    check
    @client.get_resource(*args)
  end

  def mixin(*args)
    check
    @client.get_mixin(*args)
  end

  ###

  def path_for_kind_type_identifier(*args)
    check
    @client.path_for_kind_type_identifier(*args)
  end

  def path_for_instance(*args)
    check
    @client.path_for_instance(*args)
  end

  def sanitize_instance_link(*args)
    check
    @client.sanitize_instance_link(*args)
  end

  private

  def check
    raise "You have to issue 'connect' first!" if @client.nil?
    raise "Client is disconnected!" unless @client.connected
  end

end
