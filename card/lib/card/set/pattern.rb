class Card
  module Set
    class Pattern
      class << self
        def concrete
          @concrete ||= []
        end

        def reset
          nonbase_loadables.each do |set_pattern|
            Set.const_remove_if_defined set_pattern.to_s.split("::").last
          end
          @concrete = []
          @card_keys = @codes = @nonbase_codes = @ids = nil
        end

        def loadables
          concrete.push(Card::Set::Abstract).reverse
        end

        def nonbase_loadables
          l = loadables
          l.delete Set::All
          l
        end

        def find pattern_code
          concrete.find { |sub| sub.pattern_code == pattern_code }
        end

        def card_keys
          @card_keys ||=
            concrete.each_with_object({}) do |set_pattern, hash|
              hash[set_pattern.pattern_id.cardname.key] = true
            end
        end

        def nonbase_codes
          @nonbase_codes ||= codes.tap { |list| list.delete :all }
        end

        def codes
          @codes ||= concrete.map(&:pattern_code).push(:abstract).reverse
        end

        def ids
          @ids ||= concrete.map(&:pattern_id)
        end
      end
    end
  end
end
