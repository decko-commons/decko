class Card
  module Query
    # The SqlStatement class generates sql from the Query classes.  However, the logic
    # is not yet as cleanly separated as it should be.

    # At present, SqlStatement contains (imho) too much knowledge about card constructs.
    # For example, all the permission and trash handling is here.
    #
    # In principle, the Query class should "interpret" statements into a few objects and
    # a clean Query hierarchy. The SqlStatement class should be able to traverse that
    # hierarchy and do little more than run "to_sql" on its parts, and in so doing
    # construct a valid SQL statement.
    class SqlStatement
      include Joins
      include Where
      include Order

      def initialize query=nil
        @query = query
        @mods = query&.mods
      end

      def build
        @fields = fields
        @tables = tables
        @joins  = joins
        @where  = where
        @group  = group
        @order  = order
        @limit_and_offset = limit_and_offset
        self
      end

      def to_s
        [
          comment, select, from, @joins, @where, @group, @order, @limit_and_offset
        ].compact.join " "
      end

      def select
        "#{leading_space}SELECT DISTINCT #{@fields}"
      end

      def from
        "FROM #{@tables}"
      end

      def leading_space
        " " * (@query.depth * 2)
      end

      def comment
        return nil unless Card.config.sql_comments && @query.comment

        "/* #{@query.comment} */\n"
      end

      def tables
        "#{@query.table} #{@query.table_alias}"
      end

      def fields
        table = @query.table_alias
        field = @mods[:return] unless @mods[:return] =~ /^_\w+/
        field = field.blank? ? :card : field.to_sym
        field = full_field(table, field)
        [field, @mods[:sort_join_field]].compact * ", "
      end

      def full_field table, field
        case field
        when :card, :raw then "#{table}.*"
        when :content    then "#{table}.db_content"
        when :name, :key then "#{table}.name, #{table}.left_id, #{table}.right_id"
        when :count      then "coalesce(count( distinct #{table}.id),0) as count"
        else
          standard_full_field table, field
        end
      end

      def standard_full_field table, field
        if ATTRIBUTES[field.to_sym] == :basic
          "#{table}.#{field}"
        else
          safe_sql field
        end
      end

      def group
        group = @mods[:group]
        "GROUP BY #{safe_sql group}" if group.present?
      end

      def limit_and_offset
        full_syntax do
          limit = @mods[:limit]
          offset = @mods[:offset]
          if limit.to_i.positive?
            string =  "LIMIT  #{limit.to_i} "
            string += "OFFSET #{offset.to_i} " if offset.present?
            string
          end
        end
      end

      def full_syntax
        @query.full? ? yield : return
      end

      def safe_sql txt
        Query.safe_sql txt
      end

      def cast_type type
        # ARDEP: connection
        cxn ||= ActiveRecord::Base.connection
        (val = cxn.cast_types[type.to_sym]) ? val[:name] : safe_sql(type)
      end
    end
  end
end
