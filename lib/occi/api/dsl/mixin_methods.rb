module Occi::Api::Dsl

  module MixinMethods

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

    def mixin(*args)
      check
      @client.get_mixin(*args)
    end

  end

end