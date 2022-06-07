class Card
  module Query
    # convert @query sort rep into order by statement
    # order information is stored in @mods[:sort_by], @mods[:sort_as], and
    # @mods[:sort_dir]
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
            dirs = order_directives
            "ORDER BY #{dirs.join ', '}" if dirs.present?
          end
        end

        def order_directives
          sort_mod = @mods[:sort_by] || @mods[:sort]
          return if sort_mod.blank?

          Array.wrap(sort_mod).map.with_index do |order_key, index|
            order_directive order_key, index
          end
        end

        def order_directive order_key, index
          field = order_field order_key
          @fields += ", #{field}"
          "#{field} #{order_dir order_key, index}"
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

        def order_dir order_key, index
          dir = @mods[:sort_dir] || @mods[:dir] # dir is DEPRECATED
          if dir.blank?
            DEFAULT_ORDER_DIRS[order_key.to_sym] || "asc"
          else
            safe_sql Array.wrap(dir)[index]
          end
        end
      end
    end
  end
end
