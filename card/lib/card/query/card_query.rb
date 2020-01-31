class Card
  module Query
    # interpret CQL queries, transform them into SQL, and run them.
    require "card/query/abstract_query"

    class CardQuery < AbstractQuery
      require "card/query/card_query/run"
      require "card/query/card_query/match_attributes"
      require "card/query/card_query/relational_attributes"
      require "card/query/card_query/reference_attributes"
      require "card/query/card_query/found_by"
      require "card/query/card_query/interpretation"
      require "card/query/card_query/normalization"
      require "card/query/card_query/sorting"
      require "card/query/card_query/conjunctions"

      include Clause
      include Run
      include MatchAttributes
      include RelationalAttributes
      include ReferenceAttributes
      include FoundBy
      include Interpretation
      include Normalization
      include Sorting
      include Conjunctions
      # Query Execution

      # By default a query returns card objects. This is accomplished by returning
      # a card identifier from SQL and then hooking into our caching system (see
      # Card::Fetch)

      def self.viewable_sql
        Card::Query::SqlStatement.new.permission_conditions("cards")
      end

      def table
        "cards"
      end

      def table_prefix
        "c"
      end

      def initialize statement, comment=nil
        super statement
        @comment = comment || default_comment
        interpret @statement
      end

      def default_comment
        return if @superquery || !Card.config.sql_comments

        statement.to_s
      end

      # Query Hierarchy
      # @root, @subqueries, and @superquery are used to track a hierarchy of
      # query objects.  This nesting allows to find, for example, cards that
      # link to cards that link to cards....

      def limit
        mods[:limit].to_i
      end

      def full?
        !superquery && mods[:return] != "count"
      end
    end
  end
end
