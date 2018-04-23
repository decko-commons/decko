class Card
  class Format
    module Nest
      module Subformat
        # note: while it is possible to have a subformat of a different class,
        # the :format_class value takes precedence over :format.
        def subformat subcard, opts={}
          subcard = subformat_card subcard
          opts = opts.merge(parent: self).reverse_merge(format_class: self.class)
          self.class.new subcard, opts
        end

        def subformat_card subcard
          return subcard if subcard.is_a? Card
          Card.fetch subcard, new: {}
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
