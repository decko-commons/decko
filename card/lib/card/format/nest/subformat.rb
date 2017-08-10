class Card
  class Format
    module Nest
      module Subformat
        def subformat subcard
          subcard = Card.fetch(subcard, new: {}) if subcard.is_a?(String)
          self.class.new subcard, parent: self, format_class: self.class,

root: @root,

                         depth: @depth + 1,
                                  form: @form,
                                  mode: @mode,
                                  context_names: @context_names
        end

        #def root
        #  parent ? parent.root : self
        #end

        def field_subformat field
          field = card.cardname.field(field) unless field.is_a?(Card)
          subformat field
        end
      end
    end
  end
end
