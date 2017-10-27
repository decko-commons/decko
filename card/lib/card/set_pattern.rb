class Card
  module Set
    class Pattern
      class << self
        def find pattern_code
          Card.set_patterns.find { |sub| sub.pattern_code == pattern_code }
        end

        def card_keys
          @card_keys ||=
            Card.set_patterns.inject({}) do |hash, set_pattern|
              card_key = Card.quick_fetch(set_pattern.pattern_code).key
              hash[card_key] = true
              hash
            end
        end

        def in_load_order
          @in_load_order ||=
            Card.set_patterns.reverse.map(&:pattern_code).unshift :abstract
        end
      end

      class Abstract
        class << self
          attr_accessor :pattern_code, :pattern_id, :junction_only,
                        :assigns_type, :anchorless, :anchor_parts_count

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
            !!anchorless
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
        end

        # Instance methods

        def initialize card
          unless self.class.anchorless?
            @anchor_name = self.class.anchor_name(card).to_name
            @anchor_id = find_anchor_id card
          end
          self
        end

        def find_anchor_id card
          if self.class.respond_to? :anchor_id
            self.class.anchor_id card
          else
            Card.fetch_id @anchor_name
          end
        end

        def module_key
          if defined? @module_key
            @module_key
          else
            @module_key = self.class.module_key(anchor_codenames)
          end
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
            Card::Codename[part_id] || return
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
          if self.class.anchorless?
            caps_part
          else
            "#{caps_part}-#{@anchor_name.safe_key}"
          end
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

    class Type < Pattern::Abstract
      def initialize card
        super
        # support type inheritance
        @inherit_card = card unless module_key
      end

      def lookup_module_list modules_hash
        lookup_key = module_key || inherited_key
        modules_hash[lookup_key] if lookup_key
      end

      private

      def inherited_key
        if defined?(@inherited_key)
          @inherited_key
        else
          @inherited_key = lookup_inherited_key
        end
      end

      def lookup_inherited_key
        return unless @inherit_card
        card = @inherit_card
        @inherit_card = nil
        return unless (type_code = default_type_code card)
        mod_key = "Type::#{type_code.to_s.camelize}"
        mod_key if mods_exist_for_key? mod_key
      end

      def default_type_code card
        default_rule = card.rule_card :default
        default_rule && default_rule.type_code
      end

      def mods_exist_for_key? mod_key
        list_of_hashes = Card::Set.modules[:nonbase_format].values
        list_of_hashes << Card::Set.modules[:nonbase]
        list_of_hashes.any? { |h| h[mod_key] }
      end
    end
  end
end
