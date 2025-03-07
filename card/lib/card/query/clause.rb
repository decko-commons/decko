class Card
  module Query
    # shared methods for query clauses
    module Clause
      #    attr_accessor :clause

      def safe_sql text
        Query.safe_sql text
      end

      def quote v
        connection.quote(v)
      end

      def connection
        @connection ||= ActiveRecord::Base.connection
      end
    end
  end
end
