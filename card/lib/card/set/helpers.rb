class Card
  module Set
    # These helper methods provide easy access to metadata, such as information about
    # the set modified by a module. These methods are seldom used by Monkeys; they are
    # primarily Platypus tools.
    module Helpers
      SET_PATTERN_TEST_REGEXP = /^(?<pattern>\w+)_set\?$/

      # @return [String] short name of card module. For example, returns Type::User for
      # Card::Set::Type::User
      def shortname
        first = 2 # shortname eliminates Card::Set
        last = first + num_set_parts(pattern_code)
        set_name_parts[first..last].join "::"
      end

      # @return [String] name of card module with underscores. For example, returns
      # Card__Set__Type__User for Card::Set::Type::User
      def underscored_name
        shortname.tr(":", "_").underscore
      end

      # @return [Array] list of strings of parts of set module's name
      # Eg, returns ["Card", "Set", "Type", "User"] for Card::Set::Type::User
      def set_name_parts
        @set_name_parts ||= name.split "::"
      end

      # @return [Symbol] codename associated with set's pattern. Eg :type, :right, etc
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

      # @return [true/false]
      # handles all_set?, abstract_set?, type_set?, etc.
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

      def format_modules format_sym, test: true
        if base_format_modules?
          [format_module(format_sym)]
        elsif abstract_set?
          abstract_format_modules format_sym, test
        else
          nonbase_format_modules format_sym
        end
      end

      def format_module format_sym
        const_get Card::Format.format_class_name(format_sym)
      end

      private

      # @return [Symbol] base_format,
      def set_format_type_key
        @set_format_type_key ||= :"#{set_type_key}_format"
      end

      def set_type_key
        if all_set?
          :base
        elsif abstract_set?
          :abstract
        else
          :nonbase
        end
      end

      def test_set
        # rubocop:disable Security/Eval
        ::Card::Set::Self.const_remove_if_defined :TestSet
        eval <<-RUBY, binding, __FILE__, __LINE__ + 1
          class ::Card::Set::Self
            module TestSet
              extend Card::Set
              include_set #{name}
            end
          end
        RUBY
        ::Card::Set::Self::TestSet
        # rubocop:enable Security/Eval
      end

      def base_format_modules?
        !set_format_type_key || set_format_type_key == :base_format
      end

      def abstract_format_modules format_sym, test
        [(test ? test_set : self).format_module(format_sym)]
      end

      def nonbase_format_modules format_sym
        format_class = Card::Format.format_class format: format_sym
        Card::Set.modules[set_format_type_key][format_class][shortname] || []
      end

      def num_set_parts pattern_code
        return 1 if pattern_code == :abstract

        Pattern.find(pattern_code).anchor_parts_count
      end
    end
  end
end
