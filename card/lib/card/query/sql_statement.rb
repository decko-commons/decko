class Card
  module Query
    class SqlStatement
      include Joins
      include Where

      def initialize query=nil
        @query = query
        @mods = query && query.mods
      end

      def build
        @fields = fields
        @tables = tables
        @joins  = joins @query.all_joins
        @where  = where
        @group  = group
        @order  = order
        @limit_and_offset = limit_and_offset
        self
      end

      def to_s
        [comment,
         "SELECT #{@fields}",
         "FROM #{@tables}",
         @joins,
         @where,
         @group,
         @order,
         @limit_and_offset
        ].compact * "\n"
      end

      def comment
        return nil unless Card.config.sql_comments && @query.comment
        "/* #{@query.comment} */"
      end

      def tables
        "#{@query.table} #{@query.table_alias}"
      end

      def fields
        table = @query.table_alias
        field = @mods[:return] unless @mods[:return] =~ /_\w+/
        field = field.blank? ? :card : field.to_sym
        field = full_field(table, field)
        [field, @mods[:sort_join_field]].compact * ", "
      end

      def full_field table, field
        case field
        when :raw      then "#{table}.*"
        when :card     then "#{table}.*"
        when :content  then "#{table}.db_content"
        when :count
          "coalesce(count( distinct #{table}.id),0) as count"
        else
          if ATTRIBUTES[field.to_sym] == :basic
            "#{table}.#{field}"
          else
            safe_sql field
          end
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
          if limit.to_i > 0
            string =  "LIMIT  #{limit.to_i} "
            string += "OFFSET #{offset.to_i} " if offset.present?
            string
          end
        end
      end

      def full_syntax
        @query.full? ? yield : return
      end

      def order
        full_syntax do
          order_key ||= @mods[:sort].blank? ? "update" : @mods[:sort]

          order_directives = [order_key].flatten.map do |key|
            dir = if @mods[:dir].blank?
                    DEFAULT_ORDER_DIRS[key.to_sym] || "asc"
                  else
                    safe_sql @mods[:dir]
                  end
            sort_field key, @mods[:sort_as], dir
          end.join ", "
          "ORDER BY #{order_directives}"
        end
      end

      def sort_field key, as, dir
        table = @query.table_alias
        order_field =
          case key
          when "id"             then "#{table}.id"
          when "update"         then "#{table}.updated_at"
          when "create"         then "#{table}.created_at"
          when /^(name|alpha)$/ then "#{table}.key"
          when "content"        then "#{table}.db_content"
          when "relevance"      then "#{table}.updated_at" # deprecated
          else
            safe_sql(key)
          end
        order_field = "CAST(#{order_field} AS #{cast_type(safe_sql as)})" if as
        @fields += ", #{order_field}"
        "#{order_field} #{dir}"
      end

      def safe_sql txt
        txt = txt.to_s
        if txt =~ /[^\w\*\(\)\s\.\,]/
          raise "WQL contains disallowed characters: #{txt}"
        else
          txt
        end
      end

      def cast_type type
        cxn ||= ActiveRecord::Base.connection
        (val = cxn.cast_types[type.to_sym]) ? val[:name] : safe_sql(type)
      end
    end
  end
end
