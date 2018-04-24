class Card
  class Query
    class Join
      attr_accessor :conditions, :side,
                    :from, :to,
                    :from_table, :to_table,
                    :from_alias, :to_alias,
                    :from_field, :to_field,
                    :superjoin, :subjoins

      # The example clause:
      # cards left join card_actions on cards.id =
      def initialize opts={}
        from_and_to opts
        opts.each do |key, value|
          send "#{key}=", value if value.present?
        end
        @from_field ||= :id
        @to_field   ||= :id

        @conditions = Array(@conditions).compact
        @subjoins = []
        register_superjoin
      end

      def side
        if !@side.nil?
          @side.to_s.upcase
        else
          in_or = from && from.is_a?(Card::Query) && from.mods[:conj] == "or"
          @side = in_or ? "LEFT" : nil
        end
      end

      def from_and_to opts
        [:from, :to].each do |side|
          directional_hash_for_object(side, opts[side]).map do |key, value|
            opts[:"#{side}_#{key}"] ||= value
          end
        end
      end

      def join_join side, object
        raise "to: cannot be Join" if side == :to
        dir_hash object.to_table, object.to_alias
      end

      def directional_hash_for_object side, object
        case object
          when nil         then return
          when Array       then dir_hash(*object)
          when Card::Query then dir_hash "cards", object.table_alias
          when Reference   then dir_hash "card_references", object.table_alias
          when Join        then join_join side, object
          else             raise "invalid #{side} option: #{object}"
        end
      end

      def dir_hash table, table_alias, field=nil
        hash = { table: table, alias: table_alias }
        hash[:field] = field if field
        hash
      end
      
      def side
        if !@side.nil?
          @side
        else
          in_or = from && from.is_a?(Card::Query) && from.mods[:conj] == "or"
          @side = in_or ? "LEFT" : nil
        end
      end

      def left?
        side == "LEFT"
      end

      def in_left?
        if !@in_left.nil?
          @in_left
        else
          @in_left = left? || (!@superjoin.nil? && @superjoin.in_left?)
        end
      end
    end
  end
end
