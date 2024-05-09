module Cardio
  class Mod
    class Sow
      # Fetch sow data form cards
      module CardSource
        def new_data_from_cards
          cards.map { |c| c.pod_hash field_tags: field_tag_marks }
        end

        def field_tag_marks
          @field_tag_marks ||= @field_tags.to_s.split(",").map do |mark|
            mark.strip.cardname.codename_or_string
          end
        end

        def cards
          if @name
            cards_from_name
          elsif @cql
            Card.search JSON.parse(@cql).reverse_merge(limit: 0)
          else
            raise Card::Error::NotFound, "must specify either name (-n) or CQL (-c)"
          end
        end

        def cards_from_name
          case @items
          when :only then item_cards
          when true  then main_cards + item_cards
          else            main_cards
          end
        end

        def item_cards
          main_cards.map(&:item_cards).flatten
        end

        def main_cards
          @main_cards ||= @name.split(",").map { |n| require_card n }
        end

        def require_card name
          Card.fetch(name) || raise(Card::Error::NotFound, "card not found: #{name}")
        end
      end
    end
  end
end
