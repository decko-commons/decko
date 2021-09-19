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
        abstract_set? ? :abstract_format : :nonbase_format
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
    end
  end
end
