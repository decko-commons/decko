class Card
  class Name
    module All
      # Card methods for handling name parts, eg A and B are both parts of A+B
      module Parts
        def left *args
          case
          when simple?    then nil
          when superleft then superleft
          when name_is_changing? && name.to_name.trunk_name == name_before_act.to_name
            nil # prevent recursion when, eg, renaming A+B to A+B+C
          else
            Card.fetch name.left, *args
          end
        end

        def left_or_new args={}
          left(args) || Card.new(args.merge(name: name.left))
        end

        def right *args
          Card.fetch(name.right, *args) unless simple?
        end

        def trunk *args
          simple? ? self : left(*args)
        end

        def tag *args
          simple? ? self : Card.fetch(name.right, *args)
        end

        def right_id= cardish
          write_card_or_id :right_id, cardish
        end

        def left_id= cardish
          write_card_or_id :left_id, cardish
        end

        private

        def write_card_or_id attribute, cardish
          when_id_exists(cardish) { |id| write_attribute attribute, id }
        end

        def when_id_exists cardish, &block
          if (card_id = Card.id cardish)
            yield card_id
          elsif cardish.is_a? Card
            with_id_after_store cardish, &block
          else
            yield cardish # eg nil
          end
        end

        # subcards are usually saved after super cards;
        # after_store forces it to save the subcard first
        # and callback afterwards
        def with_id_after_store subcard
          add_subcard subcard
          subcard.director.after_store { |card| yield card.id }
        end
      end
    end
  end
end
