class Card
  module Env
    class Success
      # The success "target" is the destination upon success.
      #
      # @card, @name, @id, etc all refer to the target card
      module Target
        def target= value
          @id = @name = @card = nil
          @target = process_target value
        end

        def target name_context=@name_context
          card(name_context) || @target || Card.fetch(name_context)
        end

        def mark= value
          if (id = Card.id value)
            @id = id
          elsif value.is_a? Card
            @card = value
          else
            self.target = value
          end
        end

        # @deprecated
        def id= id
          # for backwards compatibility use mark here.
          # id was often used for the card name
          self.mark = id
        end

        def type= type
          @new_args[:type] = type
        end

        def type_id= type_id
          @new_args[:type_id] = type_id.to_i
        end

        def content= content
          @new_args[:content] = content
        end

        def card name_context=@name_context
          if @card
            @card
          elsif @id
            Card.fetch @id
          elsif @name
            Card.fetch @name.to_name.absolute(name_context), new: @new_args
          end
        end

        private

        def process_target value
          case value
          when ""
            ""
          when "*previous", ":previous", :previous
            Card::Env.previous_location
          when %r{^(http|/)}
            value
          else
            @name = Name[value]
          end
        end
      end
    end
  end
end
