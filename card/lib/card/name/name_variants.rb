class Card
  class Name
    module NameVariants
      @@variant_methods = %i[capitalize singularize pluralize titleize
                             downcase upcase swapcase reverse succ]
      @@variant_aliases = { capitalized: :capitalize, singular: :singularize,
                            plural: :pluralize,       title: :titleize }

      def vary variants
        variants.to_s.split(/[\s,]+/).inject(s) do |name, variant|
          variant = @@variant_aliases[variant.to_sym] || variant.to_sym
          @@variant_methods.include?(variant) ? name.send(variant) : name
        end
      end

      # @return [Card::Name] standardized based on card names
      def standard
        self.class.compose(parts.map { |part| Card.fetch_name(part) || part })
      end

      def card
        Card.fetch self, new: {}
      end

      def card_id
        Lexicon.id self
      end

      # @return [Symbol] codename of card with name
      def codename
        Codename[card_id]
      end

      def codename_or_string
        codename || s
      end

      def alternative
        Card.generate_alternative_name self
      end
    end
  end
end
