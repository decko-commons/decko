class Card
  module Set
    module Helpers
      SET_PATTERN_TEST_REGEXP = /^(?<pattern>\w+)_set\?$/

      def shortname
        first = 2 # shortname eliminates Card::Set
        last = first + num_set_parts(pattern_code)
        set_name_parts[first..last].join "::"
      end

      def underscore
        shortname.tr(":", "_").underscore
      end

      def num_set_parts pattern_code
        return 1 if pattern_code == :abstract

        Pattern.find(pattern_code).anchor_parts_count
      end

      def set_format_type_key
        :"#{set_type_key}_format"
      end

      def set_type_key
        all_set? ? :base : (abstract_set? ? :abstract : :nonbase)
      end

      def set_name_parts
        @set_name_parts ||= name.split "::"
      end

      def pattern_code
        @pattern_code ||= set_name_parts[2].underscore.to_sym
      end

      # handles all_set?, abstract_set?, type_set?, etc.
      def method_missing method_name, *args
        if (matches = method_name.match SET_PATTERN_TEST_REGEXP)
          pattern_code == matches[:pattern].to_sym
        else
          super
        end
      end

      def respond_to_missing? method_name, _include_private=false
        method_name.match? SET_PATTERN_TEST_REGEXP
      end

      def modules
        if all_set?
          [self]
        elsif abstract_set?
          [test_set]
        else
          Set.modules[:nonbase][shortname] || []
        end
      end

      def format_modules format_sym
        type_key = set_format_type_key
        if !type_key || type_key == :base_format
          [format_module(format_sym)]
        elsif abstract_set?
          test_set.format_modules format_sym
        else
          format_class = Card::Format.format_class format: format_sym
          Card::Set.modules[type_key][format_class][shortname] || []
        end
      end

      def format_module format_sym
        const_get Card::Format.format_class_name(format_sym)
      end

      def test_set
        # rubocop:disable Lint/Eval
        ::Card::Set::Self.const_remove_if_defined :TestSet
        eval <<-RUBY
          class ::Card::Set::Self
            module TestSet
              extend Card::Set
              include_set #{self.name}
            end
          end
        RUBY
        ::Card::Set::Self::TestSet
        # rubocop:enable Lint/Eval
      end
    end
  end
end
