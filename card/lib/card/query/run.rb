class Card
  class Query

    def self.run statement, comment=nil
      new(statement, comment).run
    end

    module Run
      # run the current query
      # @return array of card objects by default
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

      def name_result record, pattern
        process_name record["name"], pattern
      end

      def card_result record, _field
        if alter_results?
          Card.fetch alter_result(record["name"]), new: {}
        else
          fetch_or_instantiate record
        end
      end

      def fetch_or_instantiate record
        card = Card.retrieve_from_cache record["key"]
        unless card
          card = Card.instantiate record
          Card.write_to_cache card, {}
        end
        card.include_set_modules
        card
      end

      def run_sql
        # puts "\nstatement = #{@statement}"
        # puts "sql = #{sql}"
        ActiveRecord::Base.connection.select_all(sql)
      end

      def process_name name, pattern
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
