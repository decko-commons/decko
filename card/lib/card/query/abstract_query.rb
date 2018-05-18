class Card
  module Query
    # superclass for CardQuery, ReferenceQuery, ActQuery, and ActionQuery
    # handles query hierarchy
    class AbstractQuery
      include QueryHelper
      attr_reader :statement, :mods, :conditions, :vars,
                  :subqueries, :superquery, :comment
      attr_accessor :joins, :conditions_on_join, :table_seq, :fasten

      def initialize statement, comment=nil
        @subqueries = []
        @conditions = []
        @joins = []
        @mods = {}

        @statement = statement.clone

        @context    = @statement.delete(:context) || nil
        @fasten     = @statement.delete(:fasten)  || :join
        @superquery = @statement.delete(:superquery) || nil

        @vars       = initialize_vars
      end

      def initialize_vars
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
        Query::SqlStatement.new(self).build.to_s
      end

      def root
        @root ||= @superquery ? @superquery.root : self
      end

      def subquery opts={}
        klass = opts.delete(:class) || Query
        subquery = klass.new opts.merge(superquery: self)
        @subqueries << subquery
        subquery
      end
    end
  end
end
