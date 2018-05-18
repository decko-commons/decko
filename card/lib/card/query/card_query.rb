class Card
  module Query
    # interpret CQL queries, transform them into SQL, and run them.
    class CardQuery < AbstractQuery
      include Clause
      include Run
      include SpecialAttributes
      include RelationalAttributes
      include AttributeHelper
      include Interpretation
      include Sorting
      include Conjunctions
      # Query Execution

      # By default a query returns card objects. This is accomplished by returning
      # a card identifier from SQL and then hooking into our caching system (see
      # Card::Fetch)

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

      def sql
        @sql ||= SqlStatement.new(self).build.to_s
      end

      # Query Hierarchy
      # @root, @subqueries, and @superquery are used to track a hierarchy of
      # query objects.  This nesting allows to find, for example, cards that
      # link to cards that link to cards....

      def context
        if !@context.nil?
          @context
        else
          @context = @superquery ? @superquery.context : ""
        end
      end

      def limit
        mods[:limit].to_i
      end

      def full?
        !superquery && mods[:return] != "count"
      end
    end
  end
end
