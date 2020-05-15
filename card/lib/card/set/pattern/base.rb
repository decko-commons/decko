class Card
  module Set
    class Pattern
      # class from which set patterns inherit
      class Base
        class << self
          attr_accessor :pattern_code, :pattern_id, :junction_only,
                        :assigns_type, :anchorless
          attr_writer :anchor_parts_count

          def new card
            super if pattern_applies? card
          end

          def register pattern_code, opts={}
            if (self.pattern_id = Card::Codename.id(pattern_code))
              self.pattern_code = pattern_code
              Card.set_patterns.insert opts.delete(:index).to_i, self
              self.anchorless = !respond_to?(:anchor_name)
              opts.each { |key, val| send "#{key}=", val }
            else
              warn "no codename for pattern_code #{pattern_code}"
            end
          end

          def junction_only?
            junction_only == true
          end

          def anchorless?
            anchorless
          end

          def pattern
            Card.fetch(pattern_id, skip_modules: true).name
          end

          def pattern_applies? card
            junction_only? ? card.name.junction? : true
          end

          def anchor_parts_count
            @anchor_parts_count ||= (anchorless? ? 0 : 1)
          end

          def module_key anchor_codes
            return pattern_code.to_s.camelize if anchorless?
            return unless anchor_codes # is this not an error?

            ([pattern_code] + anchor_codes).map { |code| code.to_s.camelize }.join "::"
          end

          # label for set pattern if no anchor is given
          def generic_label
            label nil
          end
        end

        # Instance methods

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

      module Helper
        private

        def left_type card
          card.superleft&.type_name || quick_type(card.name.left_name)
        end

        def quick_type name
          if name.present?
            card = Card.fetch name, skip_modules: true, new: {}
            card.include_set_modules if card.new? && name.to_name.junction?
            card&.type_name
          else
            "RichText"
          end
        end
      end
    end
  end
end
