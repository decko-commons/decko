class Card
  module Set
    module Helpers
      def shortname
        parts = name.split "::"
        first = 2 # shortname eliminates Card::Set
        pattern_code = parts[first].underscore.to_sym
        last = first + num_set_parts(pattern_code)
        parts[first..last].join "::"
      end

      # move to Set::Pattern?
      def num_set_parts pattern_code
        return 1 if pattern_code == :abstract
        Pattern.find(pattern_code).anchor_parts_count
      end

      def abstract_set?
        name =~ /^Card::Set::Abstract::/
      end

      def all_set?
        name =~ /^Card::Set::All::/
      end
    end
  end
end
