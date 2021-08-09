class Card
  module Set
    class Pattern
      class << self
        def concrete
          @concrete ||= []
        end

        def reset
          reloadables.each do |set_pattern|
            Set.const_remove_if_defined set_pattern.to_s.split("::").last
          end
          @concrete = []
          @card_keys = @codes = @nonbase_codes = @ids = nil
        end

        def reloadables
          r = concrete.push(Abstract)
          r.delete Set::All
          r
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

        def grouped_codes with_all: true
          g = [[:abstract], nonbase_codes.reverse]
          g.unshift [:all] if with_all
          g
        end

        def ids
          @ids ||= concrete.map(&:pattern_id)
        end

        private

        def codes
          @codes ||= concrete.map(&:pattern_code)
        end

        def nonbase_codes
          @nonbase_codes ||= codes.tap { |list| list.delete :all }
        end
      end
    end
  end
end
