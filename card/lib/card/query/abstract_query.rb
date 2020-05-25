class Card
  module Query
    # superclass for CardQuery, ReferenceQuery, ActQuery, and ActionQuery
    #
    # Each of the Query classes handle interpretation of hash "statements"
    # into a number of objects known to the SqlStatement class, including
    # @conditions, @joins, @comment, and the catch-all @mods
    #
    # Sql queries involving multiple tables are made possible by the query
    # hierarchy as tracked by subqueries (children) and superqueries (parents).
    # For example, if one card links to another, then this can be represented
    # as a CardQuery with a ReferenceQuery child that in turn has another
    # CardQuery as its child.
    #
    # See AbstractQuery::Tie for more on how tables can be connected.
    class AbstractQuery
      include QueryHelper
      include Tie

      attr_reader :statement, :mods, :conditions, :vars,
                  :subqueries, :superquery, :comment, :negate
      attr_accessor :joins, :conditions_on_join

      def initialize statement, _comment=nil
        @subqueries = []
        @conditions = []
        @joins = []
        @mods = {}

        @statement = statement.clone
        init_instance_vars :context, :superquery, :fasten, :negate
        @vars = init_query_vars
        table_alias
      end

      def init_instance_vars *varnames
        varnames.each do |varname|
          instance_variable_set "@#{varname}", (@statement.delete(varname) || nil)
        end
      end

      def init_query_vars
        if (v = @statement.delete :vars) then v.symbolize_keys
        elsif @superquery                then @superquery.vars
        else                                  {}
        end
      end

      def interpret hash
        hash.each do |action, card|
          send action, card
        end
      end

      def full?
        false
      end

      def sql
        @sql ||= Query::SqlStatement.new(self).build.to_s
      end

      def root
        @root ||= @superquery ? @superquery.root : self
      end

      def root?
        root == self
      end

      def subquery opts={}
        klass = opts.delete(:class) || Query
        subquery = klass.new opts.merge(superquery: self)
        @subqueries << subquery
        subquery
      end

      def context
        if !@context.nil?
          @context
        else
          @context = superquery ? superquery.context : ""
        end
      end

      def depth
        @depth ||= case
                   when !superquery       then 0
                   when fasten == :direct then superquery.depth
                   else                        superquery.depth + 1
                   end
      end
    end
  end
end
