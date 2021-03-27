class Card
  module Set
    class Pattern
      # class from which set patterns inherit
      class Base
        extend ClassMethods

        def initialize card
          return if self.class.anchorless?
          @anchor_name = self.class.anchor_name(card).to_name
          @anchor_id = find_anchor_id card
        end

        def find_anchor_id card
          self.class.try(:anchor_id, card) || Card.fetch_id(@anchor_name)
        end

        def module_key
          return @module_key if defined? @module_key
          @module_key = self.class.module_key anchor_codenames
        end

        def lookup_module_list modules_hash
          module_key && modules_hash[module_key]
        end

        def module_list
          lookup_module_list Card::Set.modules[:nonbase]
        end

        def format_module_list klass
          hash = Card::Set.modules[:nonbase_format][klass]
          hash && lookup_module_list(hash)
        end

        def anchor_codenames
          anchor_parts.map do |part|
            part_id = Card.fetch_id part
            Card::Codename[part_id] || break
          end
        end

        def anchor_parts
          return [@anchor_name] unless anchor_parts_count > 1

          parts = @anchor_name.parts
          if parts.size <= anchor_parts_count
            parts
          else
            # handles cases where anchor is a compound card, eg A+B+*self
            [@anchor_name[0..-anchor_parts_count]] + parts[(-anchor_parts_count + 1)..-1]
          end
        end

        def anchor_parts_count
          self.class.anchor_parts_count
        end

        def pattern
          @pattern ||= self.class.pattern
        end

        def to_s
          self.class.anchorless? ? pattern.s : "#{@anchor_name}+#{pattern}"
        end

        def inspect
          "<#{self.class} #{to_s.to_name.inspect}>"
        end

        def safe_key
          caps_part = self.class.pattern_code.to_s.tr(" ", "_").upcase
          self.class.anchorless? ? caps_part : "#{caps_part}-#{@anchor_name.safe_key}"
        end

        def rule_set_key
          if self.class.anchorless?
            self.class.pattern_code.to_s
          elsif @anchor_id
            "#{@anchor_id}+#{self.class.pattern_code}"
          end
        end
      end
    end
  end
end
