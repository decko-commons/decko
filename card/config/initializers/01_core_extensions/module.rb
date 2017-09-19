module CoreExtensions
  module Module
    def const_get_if_defined const
      const_get(const, false) if const_defined?(const, false)
    end

    def const_remove_if_defined const
      remove_const const if const_defined? const
    end

    def const_get_or_set const
      const_get_if_defined(const) || const_set(const, yield)
    end

    def add_set_modules list
      Array(list).each do |mod|
        include mod if mod.instance_methods.any? || mod.respond_to?(:included)
        if (class_methods = mod.const_get_if_defined(:ClassMethods))
          extend class_methods
        end
      end
    end

    # Encapsulates the common pattern of:
    #
    #   alias_method :foo_without_feature, :foo
    #   alias_method :foo, :foo_with_feature
    #
    # With this, you simply do:
    #
    #   alias_method_chain :foo, :feature
    #
    # And both aliases are set up for you.
    #
    # Query and bang methods (foo?, foo!) keep the same punctuation:
    #
    #   alias_method_chain :foo?, :feature
    #
    # is equivalent to
    #
    #   alias_method :foo_without_feature?, :foo?
    #   alias_method :foo?, :foo_with_feature?
    #
    # so you can safely chain foo, foo?, foo! and/or foo= with the same feature.
    #
    # has been removed in rails 5
    def alias_method_chain(target, feature)
      # Strip out punctuation on predicates, bang or writer methods since
      # e.g. target?_without_feature is not a valid method name.
      aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
      yield(aliased_target, punctuation) if block_given?

      with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
      without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

      alias_method without_method, target
      alias_method target, with_method

      case
      when public_method_defined?(without_method)
        public target
      when protected_method_defined?(without_method)
        protected target
      when private_method_defined?(without_method)
        private target
      end
    end
  end
end
