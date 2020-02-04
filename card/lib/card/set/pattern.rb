class Card
  module Set
    class Pattern
      require "card/set/type"
      # ::Card::Set::Type

      class << self
        def reset
          (Card.set_patterns << Card::Set::Abstract).each do |set_pattern|
            Card::Set.const_remove_if_defined set_pattern.to_s.split("::").last
          end
          Card.set_patterns = []
          @card_keys = @in_load_order = nil
        end

        def find pattern_code
          Card.set_patterns.find { |sub| sub.pattern_code == pattern_code }
        end

        def card_keys
          @card_keys ||=
            Card.set_patterns.each_with_object({}) do |set_pattern, hash|
              card_key = Card.quick_fetch(set_pattern.pattern_code).key
              hash[card_key] = true
            end
        end

        def in_load_order
          @in_load_order ||=
            Card.set_patterns.reverse.map(&:pattern_code).unshift :abstract
        end
      end
    end
  end
end
