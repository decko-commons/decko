class Card
  module Set
    class Pattern
      # methods for Set::Pattern classes
      module ClassMethods
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
          junction_only? ? card.name.compound? : true
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

        private

        def left_type card
          card.superleft&.type_name || quick_type(card.name.left_name)
        end

        def quick_type name
          if name.present?
            card = Card.fetch name, skip_modules: true, new: {}
            card.include_set_modules if card.new? && name.to_name.compound?
            card&.type_name
          else
            "RichText"
          end
        end
      end
    end
  end
end
