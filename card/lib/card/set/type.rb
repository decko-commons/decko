class Card
  module Set
    class Type < Pattern::Base
      cattr_accessor :assignment
      self.assignment = {}

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
        return unless (card = @inherit_card)

        @inherit_card = nil
        return unless (type_code = default_type_code card)

        mod_key = "Type::#{type_code.to_s.camelize}"
        mod_key if mods_exist_for_key? mod_key
      end

      def default_type_code card
        card.rule_card(:default, skip_modules: true)&.type_code
      end

      def mods_exist_for_key? mod_key
        list_of_hashes = Card::Set.modules[:nonbase_format].values
        list_of_hashes << Card::Set.modules[:nonbase]
        list_of_hashes.any? { |h| h[mod_key] }
      end
    end
  end
end
