class Card
  module Query
    module Clause
      #    attr_accessor :clause

      def safe_sql text
        Query.safe_sql text
      end

      def quote v
        connection.quote(v)
      end

      # ARDEP: connection
      def connection
        @connection ||= ActiveRecord::Base.connection
      end
    end
  end
end
