class Card
  module Set
    class Pattern
      class << self
        def reset
          nonbase_loadables.each do |set_pattern|
            Card::Set.const_remove_if_defined set_pattern.to_s.split("::").last
          end
          Card.set_patterns = []
          @card_keys = nil
        end

        def loadables
          Card.set_patterns.push(Card::Set::Abstract).reverse
        end

        def nonbase_loadables
          l = loadables
          l.delete Card::Set::All
          l
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

        def nonbase_loadable_codes
          loadable_codes.tap { |l| l.delete :all }
        end

        def loadable_codes
          Card.set_patterns.map(&:pattern_code).push(:abstract).reverse
        end
      end
    end
  end
end
