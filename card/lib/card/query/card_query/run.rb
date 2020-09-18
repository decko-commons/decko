class Card
  module Query
    class CardQuery
      # run CQL queries
      module Run
        # run the current query
        # @return [Array] of card objects by default
        def run
          retrn = statement[:return].present? ? statement[:return].to_s : "card"
          return_method = :"return_#{simple_result?(retrn) ? :simple : :list}"
          send return_method, run_sql, retrn
        end

        # @return [(not an Array)]
        def return_simple sql_result, retrn
          send result_method(retrn), sql_result, retrn
        end

        # @return [Array]
        def return_list sql_results, retrn
          large_list sql_results.length if sql_results.length > 1000
          sql_results.map do |record|
            return_simple record, retrn
          end
        end

        def large_list length
          Rails.logger.info "#{length} records returned by #{@statement}"
        end

        def result_method retrn
          case
          when respond_to?(:"#{retrn}_result") then :"#{retrn}_result"
          when (retrn =~ /id$/)                then :id_result
          when (retrn =~ /_\w+/)               then :name_result
          when (retrn == "key")                then :key_result
          else                                      :default_result
          end
        end

        def count_result results, _field
          results.first["count"].to_i
        end

        def default_result record, field
          record[field]
        end

        def id_result record, field
          record[field].to_i
        end

        def raw_result record, _field
          record
        end

        def key_result record, pattern=""
          name_result(record, pattern).to_name.key
        end

        def name_result record, pattern=""
          name = record["name"]&.to_name
          name ||= Card::Lexicon.lex_to_name [record["left_id"], record["right_id"]]
          process_name name, pattern
        end

        def card_result record, _field
          if alter_results?
            Card.fetch name_result(record), new: {}
          else
            fetch_or_instantiate record
          end
        end

        def fetch_or_instantiate record
          card = Card.retrieve_from_cache_by_id record["id"]
          unless card
            card = Card.instantiate record
            Card.write_to_cache card
          end
          card.include_set_modules
          card
        end

        # ARDEP: connection
        def run_sql
          # puts "\nSQL = #{sql}"
          ActiveRecord::Base.connection.select_all sql
        end

        def process_name name, pattern=""
          name = pattern.to_name.absolute(name) if pattern =~ /_\w+/
          return name unless alter_results?

          alter_result name
        end

        def alter_result name
          name_parts = [statement[:prepend], name, statement[:append]].compact
          Card::Name[name_parts]
        end

        def simple_result? retrn
          retrn == "count"
        end

        def alter_results?
          statement[:prepend] || statement[:append]
        end
      end
    end
  end
end
