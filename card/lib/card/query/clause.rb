class Card
  module Query
    module Clause
      #    attr_accessor :clause

      def safe_sql text
        txt = text.to_s
        raise "WQL contains disallowed characters: #{txt}" if txt =~ /[^\w\s*().,]/

        txt
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
