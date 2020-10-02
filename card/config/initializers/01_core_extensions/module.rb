warn "core extension 5"
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
  end
end
