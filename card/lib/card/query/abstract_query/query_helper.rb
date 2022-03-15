class Card
  module Query
    class AbstractQuery
      # shared methods for queries
      module QueryHelper
        def direct_subqueries
          subqueries_with_fasten :direct
        end

        def subqueries_with_fasten fasten
          list = []
          subqueries.each do |s|
            next unless Array.wrap(fasten).include? s.fasten

            list << s
            list += s.subqueries_with_fasten s.fasten
          end
          list
        end

        def table_alias
          @table_alias ||= begin
            if fasten == :direct
              @superquery.table_alias
            else
              "#{table_prefix}#{root.table_seq}#{@table_suffix}"
            end
          end
        end

        def table_seq
          @table_seq = @table_seq ? (@table_seq + 1) : 0
        end

        def fld field_name
          "#{table_alias}.#{field_name}"
        end

        def add_condition *args
          @conditions <<
            if args.size > 1
              [args.shift, Query::Value.new(args.shift, self)]
            else
              args[0]
            end
        end

        def current_conjunction
          "AND"
        end
      end
    end
  end
end
