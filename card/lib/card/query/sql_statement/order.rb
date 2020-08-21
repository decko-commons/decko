class Card
  module Query
    # convert @query sort rep into order by statement
    # order information is stored in @mods[:sort], @mods[:sort_as], and
    # @mods[:dir]
    class SqlStatement
      ORDER_MAP = {
        "id" => "id",
        "update" => "updated_at",
        "create" => "created_at",
        "name" => "key",
        "content" => "db_content",
        "alpha" => "key",       # DEPRECATED
        "relevance" => "updated_at" # DEPRECATED
      }.freeze

      # build ORDER BY clause
      module Order
        def order
          full_syntax do
            "ORDER BY #{order_directives.join ', '}"
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
          order_as do
            if (field = ORDER_MAP[order_key])
              "#{@query.table_alias}.#{field}"
            else
              safe_sql order_key
            end
          end
        end

        def order_as
          field = yield
          return field unless (as = @mods[:sort_as])

          "CAST(#{field} AS #{cast_type(safe_sql(as))})"
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
