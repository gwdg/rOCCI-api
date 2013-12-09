module Occi::Api::Dsl

  module HelperMethods

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

  end

end