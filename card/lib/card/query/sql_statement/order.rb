class Card
  module Query
    class SqlStatement
      # build ORDER BY clause
      module Order
        def order
          full_syntax do
            "ORDER BY #{order_directives.join ', ' }"
          end
        end

        def order_directives
          Array.wrap(order_config).map do |order_key|
            order_directive order_key
          end
        end

        def order_directive order_key
          field = order_field order_key
          @fields += ", #{field}"
          "#{field} #{order_dir order_key}"
        end

        def order_field order_key
          table = @query.table_alias
          order_as do
            case order_key
              when "id"             then "#{table}.id"
              when "update"         then "#{table}.updated_at"
              when "create"         then "#{table}.created_at"
              when /^(name|alpha)$/ then "#{table}.key"
              when "content"        then "#{table}.db_content"
              when "relevance"      then "#{table}.updated_at" # deprecated
              else                       safe_sql order_key
            end
          end
        end

        def order_as
          field = yield
          return field unless (as = @mods[:sort_as])
          "CAST(#{field} AS #{cast_type(safe_sql as)})"
        end

        def order_dir order_key
          if @mods[:dir].blank?
            DEFAULT_ORDER_DIRS[order_key.to_sym] || "asc"
          else
            safe_sql @mods[:dir]
          end
        end

        def order_config
          @mods[:sort].blank? ? "update" : @mods[:sort]
        end
      end
    end
  end
end
