class Card
  module Set
    module Pattern
      # pattern-related Card instance methods
      module All
        def patterns?
          defined? @patterns
        end

        def concrete_patterns
          @concrete_patterns ||= Pattern.concrete.map { |sub| sub.new self }.compact
        end

        # new cards do not
        def patterns
          @patterns ||= (new_card? ? concrete_patterns[1..-1] : concrete_patterns)
        end

        def reset_patterns
          # Rails.logger.info "resetting patterns: #{name}"
          @patterns = @concrete_patterns = nil
          @template = @virtual = nil
          @set_mods_loaded = @set_modules = @set_names = @rule_lookup_keys = nil
          @compound_only = nil # only applies to set cards
          true
        end

        def safe_set_keys
          patterns.map(&:safe_key).reverse * " "
        end

        def set_modules
          @set_modules ||=
            concrete_patterns[0..-2].reverse.map(&:module_list).flatten.compact
        end

        def set_format_modules klass
          @set_format_modules ||= {}
          @set_format_modules[klass] =
            concrete_patterns[0..-2].reverse.map do |pattern|
              pattern.format_module_list klass
            end.flatten.compact
        end

        def set_names
          @set_names = patterns.map(&:to_s) if @set_names.nil?
          @set_names
        end

        def in_set? set_module
          patterns.map(&:module_key).include? set_module.shortname
        end

        def rule_lookup_keys
          @rule_lookup_keys ||= patterns.map(&:rule_lookup_key).compact
        end

        def include_module? set
          singleton_class&.include? set
        end

        def each_type_assigning_module_key
          patterns.each do |p|
            next unless p.assigns_type

            module_key = p.module_key
            yield module_key if module_key
          end
        end
      end
    end
  end
end
