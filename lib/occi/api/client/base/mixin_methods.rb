module Occi::Api::Client
  module Base

    module MixinMethods

      # Looks up a mixin using its name and, optionally, a type as well.
      # Will return mixin's full location (a link) or a description.
      #
      # @example
      #    client.get_mixin "debian6"
      #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
      #    client.get_mixin "debian6", "os_tpl", true
      #     # => #<Occi::Core::Mixin>
      #    client.get_mixin "large", "resource_tpl"
      #     # => "http://my.occi.service/occi/infrastructure/resource_tpl#large"
      #    client.get_mixin "debian6", "resource_tpl" # => nil
      #
      # @param name [String] name of the mixin
      # @param type [String] type of the mixin
      # @param describe [Boolean] should we describe the mixin or return its link?
      # @return [String, Occi::Core::Mixin, nil] link, mixin description or nothing found
      def get_mixin(name, type = nil, describe = false)
        # TODO: mixin fix
        Occi::Api::Log.debug "Looking for mixin #{name.inspect} #{type.inspect} " \
                        "#{describe.inspect}"

        # TODO: extend this code to support multiple matches and regex filters
        # should we look for links or descriptions?
        describe ? describe_mixin(name, type) : list_mixin(name, type)
      end

      # Looks up a mixin using its name and, optionally, a type as well.
      # Will return mixin's full description.
      #
      # @example
      #    client.describe_mixin "debian6"
      #     # => #<Occi::Core::Mixin>
      #    client.describe_mixin "debian6", "os_tpl"
      #     # => #<Occi::Core::Mixin>
      #    client.describe_mixin "large", "resource_tpl"
      #     # => #<Occi::Core::Mixin>
      #    client.describe_mixin "debian6", "resource_tpl" # => nil
      #
      # @param name [String] name of the mixin
      # @param type [String] type of the mixin
      # @return [Occi::Core::Mixin, nil] mixin description or nothing found
      def describe_mixin(name, type = nil)
        mixins = get_mixins(type)

        mixins = mixins.to_a.select { |m| m.term == name }
        mixins.any? ? mixins.first : nil
      end

      # Looks up a mixin with a specific type, will return
      # mixin's full description.
      #
      # @param name [String] name of the mixin
      # @param type [String] type of the mixin
      # @return [Occi::Core::Mixin] mixin description
      def describe_mixin_w_type(name, type)
        describe_mixin(name, type)
      end

      # Looks up a mixin in all available mixin types, will
      # return mixin's full description. Returns always the
      # first match found, search will start in os_tpl.
      #
      # @param name [String] name of the mixin
      # @return [Occi::Core::Mixin] mixin description
      def describe_mixin_wo_type(name)
        describe_mixin(name, nil)
      end

      # Looks up a mixin using its name and, optionally, a type as well.
      # Will return mixin's full location.
      #
      # @example
      #    client.list_mixin "debian6"
      #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
      #    client.list_mixin "debian6", "os_tpl"
      #     # => "http://my.occi.service/occi/infrastructure/os_tpl#debian6"
      #    client.list_mixin "large", "resource_tpl"
      #     # => "http://my.occi.service/occi/infrastructure/resource_tpl#large"
      #    client.list_mixin "debian6", "resource_tpl" # => nil
      #
      # @param name [String] name of the mixin
      # @param type [String] type of the mixin
      # @return [String, nil] link or nothing found
      def list_mixin(name, type = nil)
        mixin = describe_mixin(name, type)
        mixin ? mixin.type_identifier : nil
      end

      # Retrieves available mixins of a specified type or all available
      # mixins if the type wasn't specified. Mixins are returned in the
      # form of mixin instances.
      #
      # @example
      #    client.get_mixins
      #     # => #<Occi::Core::Mixins>
      #    client.get_mixins "os_tpl"
      #     # => #<Occi::Core::Mixins>
      #    client.get_mixins "resource_tpl"
      #     # => #<Occi::Core::Mixins>
      #
      # @param type [String] type of mixins
      # @param include_self [Boolean] include type itself as a mixin
      # @return [Occi::Core::Mixins] collection of available mixins
      def get_mixins(type = nil, include_self = false)
        unless type.blank?
          type_id = get_mixin_type_identifier(type)
          unless type_id
            raise ArgumentError,
                  "There is no such mixin type registered in the model! #{type.inspect}"
          end

          mixins = @model.mixins.to_a.select { |m| m.related_to?(type_id) }

          # drop the type mixin itself
          mixins.delete_if { |m| m.type_identifier == type_id } unless include_self
        else
          # we did not get a type, return all mixins
          mixins = Occi::Core::Mixins.new(@model.mixins)
        end

        unless mixins.kind_of? Occi::Core::Mixins
          col = Occi::Core::Mixins.new
          mixins.each { |m| col << m }
        else
          col = mixins
        end

        col
      end

      # Retrieves available mixins of a specified type or all available
      # mixins if the type wasn't specified. Mixins are returned in the
      # form of mixin identifiers.
      #
      # @example
      #    client.list_mixins
      #     # => #<Array<String>>
      #    client.list_mixins "os_tpl"
      #     # => #<Array<String>>
      #    client.list_mixins "resource_tpl"
      #     # => #<Array<String>>
      #
      # @param type [String] type of mixins
      # @param include_self [Boolean] include type itself as a mixin
      # @return [Array<String>] collection of available mixin identifiers
      def list_mixins(type = nil, include_self = false)
        mixins = get_mixins(type, include_self)
        mixins.to_a.collect { |m| m.type_identifier }
      end

      # Retrieves available mixin types. Mixin types are presented
      # in a shortened format (i.e. not as type identifiers).
      #
      # @example
      #    client.get_mixin_types # => [ "os_tpl", "resource_tpl" ]
      #
      # @return [Array<String>] list of available mixin types
      def get_mixin_types
        get_mixins.to_a.collect { |m| m.term }
      end

      # Retrieves available mixin type identifiers.
      #
      # @example
      #    client.get_mixin_type_identifiers
      #     # => ['http://schemas.ogf.org/occi/infrastructure#os_tpl',
      #     #     'http://schemas.ogf.org/occi/infrastructure#resource_tpl']
      #
      # @return [Array<String>] list of available mixin type identifiers
      def get_mixin_type_identifiers
        list_mixins(nil)
      end

      # Retrieves available mixin type identifier for the given mixin type.
      #
      # @example
      #    client.get_mixin_type_identifier("os_tpl")
      #     # => 'http://schemas.ogf.org/occi/infrastructure#os_tpl'
      #
      # @param type [String] short mixin type
      # @return [String, nil] mixin type identifier for the given mixin type
      def get_mixin_type_identifier(type)
        return type if (type =~ URI::ABS_URI) || (type && type.start_with?('/'))

        mixins = @model.mixins.to_a.select { |m| m.term == type }
        tis = mixins.collect { |m| m.type_identifier }
        tis.uniq!

        if tis.length > 1
          raise Occi::Api::Client::Errors::AmbiguousNameError,
                "Mixin type #{type.inspect} is ambiguous, use a type identifier!"
        end

        tis.first
      end

      # Retrieves available os_tpls from the model.
      #
      # @example
      #    get_os_templates # => #<Occi::Core::Mixins>
      #
      # @return [Occi::Core::Mixins] collection containing all registered OS templates
      def get_os_templates
        get_mixins Occi::Infrastructure::OsTpl.mixin.type_identifier
      end
      alias_method :get_os_tpls, :get_os_templates

      # Retrieves available resource_tpls from the model.
      #
      # @example
      #    get_resource_templates # => #<Occi::Core::Mixins>
      #
      # @return [Occi::Core::Mixins] collection containing all registered resource templates
      def get_resource_templates
        get_mixins Occi::Infrastructure::ResourceTpl.mixin.type_identifier
      end
      alias_method :get_resource_tpls, :get_resource_templates

    end

  end
end