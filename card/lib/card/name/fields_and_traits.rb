class Card
  class Name
    # Name-based "Fields" are compound names in which the right name is treated
    # as an attribute of the left.  (Eg MyName+address)
    #
    # "Traits" are the subset of fields in which the right name corresponds to a
    # card with a codename
    module FieldsAndTraits
      # @return [String]
      def field tag_name
        field_name(tag_name).s
      end

      # @return [Card::Name]
      def field_name tag_name
        case tag_name
        when Symbol
          trait_name tag_name
        else
          tag_name = tag_name.to_s[1..-1] if tag_name.to_s[0] == "+"
          [self, tag_name].to_name
        end
      end

      # @return [True/False]
      def field_of? context
        return false unless junction?
        if context.present?
          absolute_name(context).left_name.key == context.to_name.key
        else
          s.match(/^\s*\+[^+]+$/).present?
        end
      end

      def field_only?
        relative? && stripped.to_name.parts.reject(&:blank?).first == parts.last
      end

      def relative_field_name tag_name
        field_name(tag_name).name_from self
      end

      # @return [String]
      def trait tag_code
        name = trait_name tag_code
        name.s
      end

      # @return [Card::Name]
      def trait_name tag_code
        Card::Name[self, tag_code.to_sym]
      end

      # @return [True/False]
      def trait_name? *traitlist
        return false unless junction?
        right_key = right_name.key
        traitlist.any? do |codename|
          Card::Codename.name(codename)&.key == right_key
        end
      end
    end
  end
end
