class Card
  module Query
    class CardQuery
      # handle special CQL attributes
      module SpecialAttributes
        def found_by val
          found_by_cards(val).compact.each do |card|
            subquery found_by_statement(card).merge(fasten: :direct, context: card.name)
          end
        end

        # Implements the match attribute that matches always against content and name.
        # That's different from the match operator that can be restricted to names or
        # content.
        # Example: { match: "name or content" } vs. { name: ["match", "a name"] }
        def match val
          val.gsub!(/[^#{Card::Name::OK4KEY_RE}]+/, " ")
          return nil if val.strip.empty?
          val.gsub!("*", '\\\\\\\\*')
          val_list = val.split(/\s+/).map do |v|
            name_or_content_match v
          end
          add_condition and_join(val_list)
        end

        def name_match val
          name_like "%#{val}%"
        end

        def complete val
          no_plus_card = (val =~ /\+/ ? "" : "and #{table_alias}.right_id is null")
          # FIXME: -- this should really be more nuanced --
          # it breaks down after one plus
          name_like "#{val}%", no_plus_card
        end

        def junction_complete val
          name_like ["#{val}%", "%+#{val}%"]
        end

        def extension_type _val
          # DEPRECATED LONG AGO!!!
          Rails.logger.info "using DEPRECATED extension_type in WQL"
          interpret right_plus: AccountID
        end
      end
    end
  end
end
