class Card
  module Set
    # Each deck can have countless sets of cards, each of which follows one of a small
    # list of patterns. This module provides methods for managing those patterns.
    module Pattern
      class << self
        # Pattern classes all the patterns except for Abstract.
        # They are concrete because they are defined on a set of cards
        # (while abstract sets must be included on them explicitly).
        #
        # @return [Array <Class>]
        def concrete
          @concrete ||= []
        end

        # Pattern classes that can be reloaded without reloading Card
        # (everything but all)
        # @return [Array <Class>]
        def reloadables
          concrete - [Set::All] + Abstract
        end

        # remove reloadable sets and prepare for reloading
        def reset
          reloadables.each do |set_pattern|
            Set.const_remove_if_defined set_pattern.to_s.split("::").last
          end
          @concrete = @codes = @type_assigner_codes = @nonbase_codes = @ids = nil
        end

        # finds pattern class associated with codename
        # e.g. find(:type) returns `Card::Set::Type`
        #
        # @return [Class] pattern class
        def find pattern_code
          concrete.find { |sub| sub.pattern_code == pattern_code }
        end

        # list of codenames of pattern cards
        # @return [Array <Symbol>]
        def codes
          @codes ||= concrete.to_set(&:pattern_code)
        end

        # list of lists of codenames in pattern load order
        # @return [Array <Array <Symbol>>]
        def grouped_codes with_all: true
          g = [[:abstract], nonbase_codes.reverse]
          g.unshift [:all] if with_all
          g
        end

        # list of ids of pattern cards
        # @return [Array <Integer>]
        def ids
          @ids ||= concrete.map(&:pattern_id)
        end

        private

        def nonbase_codes
          @nonbase_codes ||= codes.to_a - [:all]
        end
      end
    end
  end
end
