class Card
  class Query
    module Sorting
      SORT_BY_ITEM_JOIN_MAP = { left: "left_id", right: "right_id" }.freeze

      def sort val
        return nil unless full?
        sort_field = val[:return] || "db_content"
        val = val.clone
        item = val.delete(:item) || "left"
        if sort_field == "count"
          sort_by_count val, item
        else
          sort_by_item_join val, item, sort_field
        end
      end

      def sort_by_item_join val, item, sort_field
        join_field = sort_by_item_join_field item
        join = join_cards val, to_field: join_field,
                               side: "LEFT",
                               conditions_on_join: true
        @mods[:sort] ||= "#{join.table_alias}.#{sort_field}"
      end

      def sort_by_item_join_field item
        SORT_BY_ITEM_JOIN_MAP[item.to_sym] || sort_method_not_implemented(:join, item)
      end

      # EXPERIMENTAL!
      def sort_by_count val, item
        method_name = "sort_by_count_#{item}"
        sort_by_count_not_implemented :count, item unless respond_to? method_name
        send method_name, val
      end

      def sort_method_not_implemented method, item
        raise Card::Error::BadQuery, "sorting by ##{method}/#{item} not yet implemented"
      end

      def sort_by_count_referred_to val
        @mods[:sort] = "coalesce(count,0)" # needed for postgres
        cs = Query.new(
          return: "coalesce(count(*), 0) as count",
          group: "sort_join_field",
          superquery: self
        )
        subselect = Query.new val.merge(return: "id", superquery: self)
        cs.add_condition "referer_id in (#{subselect.sql})"
        # FIXME: - SQL generated before SQL phase
        cs.joins << Join.new(
          from: cs,
          to: %w(card_references wr referee_id)
        )
        cs.mods[:sort_join_field] = "#{cs.table_alias}.id as sort_join_field"
        # HACK!

        joins << Join.new(
          from: self,
          to: [cs, "srtbl", "sort_join_field"]
        )
      end
    end
  end
end
