class Cardname
  # Name-based "Fields" are compound names in which the right name is treated
  # as an attribute of the left.  (Eg MyName+address is a field of MyName)
  module Fields
    # @return [String]
    def field tag_name
      field_name(tag_name).s
    end

    # @return [Card::Name]
    def field_name tag
      tag = tag.to_s[1..-1] if !tag.is_a?(Symbol) && tag.to_s[0] == "+"
      [self, tag].to_name
    end

    # @return [True/False]
    def field_of? context
      return false unless compound?

      if context.present?
        absolute_name(context).left_name.key == context.to_name.key
      else
        s.match?(/^\s*\+[^+]+$/)
      end
    end

    # name is relative name containing only the rightmost part
    # @return [True/False]
    def field_only?
      relative? && stripped.parts.reject(&:blank?).first == parts.last
    end

    def relative_field_name tag_name
      field_name(tag_name).name_from self
    end
  end
end
