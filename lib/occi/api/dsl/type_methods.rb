module Occi::Api::Dsl

  module TypeMethods

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

    def action_types
      check
      @client.get_action_types
    end

    def action_type_identifier(*args)
      check
      @client.get_action_type_identifier(*args)
    end

    def action_type_identifiers
      check
      @client.get_action_type_identifiers
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

  end

end