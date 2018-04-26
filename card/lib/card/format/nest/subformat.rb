class Card
  class Format
    module Nest
      module Subformat
        def subformat subcard
          subcard = Card.fetch(subcard, new: {}) unless subcard.is_a?(Card)
          self.class.new subcard, parent: self, format_class: self.class, form: @form
        end

        def root
          @root ||= parent ? parent.root : self
        end

        def depth
          @depth ||= parent ? (parent.depth + 1) : 0
        end

        def main?
          depth.zero?
        end

        def focal? # meaning the current card is the requested card
          depth.zero?
        end

        def field_subformat field
          field = card.name.field(field) unless field.is_a?(Card)
          subformat field
        end

        def inherit variable
          variable = "@#{variable}" unless variable.to_s.start_with? "@"
          instance_variable_get(variable) || parent&.inherit(variable)
        end
      end
    end
  end
end
