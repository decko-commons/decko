class Card
  class Subcards
    # Methods for handling related subcards
    module Relate
      def field_name_to_key name
        if @context_card.name.starts_with_joint?
          relative_child(name).key
        else
          child(name).key
        end
      end

      def child name
        absolute_name = @context_card.name.field_name name
        if @keys.include? absolute_name.key
          absolute_name
        else
          relative_child name
        end
      end

      def relative_child name
        @context_card.name.relative_field_name name
      end
    end
  end
end
